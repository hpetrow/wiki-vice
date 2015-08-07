class WikiWrapper
  require 'json'
  require 'open-uri'

  CALLBACK = "https://en.wikipedia.org/w/api.php?format=json&action=query"

  def get_page(title)
    url = page_revisions_url(title)
    json = load_json(url)

    if json["continue"].nil?
      rvcontinue = false
    else
      rvcontinue = json["continue"]["rvcontinue"]
    end
    page_id = json["query"]["pages"].keys.first
    page_data = json["query"]["pages"][page_id]
    page = Page.new(title: page_data["title"], page_id: page_id)
    page.url = page_url(page_data["title"])
    page.save
    add_categories_to_page(page, page_data["categories"])
    add_revisions_to_page(page, page_data["revisions"])
    params = {continue: 10, title: title, revisions: page_data["revisions"], page: page, rvcontinue: rvcontinue}
    get_more_revisions(params)
    get_vandalism_revisions(params)
    page.save
    page
  end

  def get_user_contributions(author)
    url = user_contribs_url(author)
    json = load_json(url)

    usercontribs = json["query"]["usercontribs"]
    usercontribs.each do |data|
      page = find_page(data['title'], {pageid: data["pageid"]})
      revision = Revision.new(
        {
          revid: data["revid"],
          timestamp: data["timestamp"],
          size: data["size"],
          size_diff: data["sizediff"]
        }
      )
      revision.page = page
      revision.author = author
      revision.save
    end
  end

  def get_user_contributions(author)
    url = user_contribs_url(author)
    json = load_json(url)

    usercontribs = json["query"]["usercontribs"]
    usercontribs.each do |data|
      page = Page.find_or_create_by(title: data["title"])
      if Revision.find_by(revid: data["revid"])
        revision = Revision.find_by(revid: data["revid"])
      else
        revision = Revision.create(
          timestamp: data["timestamp"],
          size: data["size"],
          size_diff: data["sizediff"]
          )
      end
      revision.page = page
      revision.author = author
      revision.save
    end
  end

  private
  def get_more_revisions(params)
    i = 1
    loop do
      url = page_revisions_url(params[:title], {rvcontinue: params[:rvcontinue]})
      json = load_json(url)

      break if i == params[:continue] || json["continue"].nil?
      page_id = json["query"]["pages"].keys.first
      revisions = json["query"]["pages"][page_id]["revisions"]
      add_revisions_to_page(params[:page], revisions)
      i += 1
    end
  end

  def get_vandalism_revisions(params)
    base_url = page_revisions_url(params[:title])
    url = "#{base_url}&rvtag=possible%20libel%20or%20vandalism"
    json = load_json(url)

    page_id = json["query"]["pages"].keys.first
    revisions = json["query"]["pages"][page_id]["revisions"]
    add_revisions_to_page(params[:page], revisions) if !!revisions
  end

  def page_revisions_url(title, options = {})
    prop = "prop=revisions|categories"
    rvlimit = "rvlimit=50"
    titles = "titles=#{title.gsub(" ", "%20")}"
    rvdiff = "rvdiffto=prev"
    rclimit = "rclimit=10"
    redirects = "redirects"
    rvprop = "rvprop=ids|user|timestamp|comment|tags"
    url = [CALLBACK, prop, rvlimit, titles, rvdiff, rvprop, redirects]
    if options.empty?
      url.join("&")
    else
      options.each {|key, value| url << "#{key}=#{value}"}
      url.join("&")
    end
  end

  def add_revisions_to_page(page, revisions)
    revisions.each do |r|
      if (!Revision.find_by(timestamp: r['timestamp']))
        Revision.new.tap { |revision|
          revision.timestamp = r['timestamp']
          revision.content = r['diff'].nil? ? 'notcached' : r['diff']['*']
          revision.revid = r['revid']
          revision.comment = r['comment']
          revision.vandalism = vandalism?(r['tags'])

          author_name = !!r['user'] ? r['user'] : 'anonymous'
          revision.author = Author.find_or_create_by(name: author_name)
          revision.page = page
          revision.save
          page.save
        }
      end
    end
  end

  def add_categories_to_page(page, categories)
    categories.each do |c|
      category_name = /^Category:(.+)/.match(c['title'])[1]
      category = Category.find_or_create_by(name: category_name)
      page.categories << category
    end
  end

  def user_contribs_url(author)
    list = "list=usercontribs"
    ucuser = "ucuser=#{author.name}"
    uclimit = "uclimit=500"
    ucprop = "ucprop=ids|title|timestamp|comment|size|sizediff|flags|tags"
    ucnamespace = "ucnamespace=0"
    [CALLBACK, list, ucuser, uclimit, ucprop, ucnamespace].join("&")
  end

  def page_url(title)
    "https://en.wikipedia.org/wiki/" + title.gsub(" ", "_")
  end

  def revision_content_url(revision)
    prop = "prop=revisions"
    revids = "revids=#{revision.revid}"
    rvdiffto = "rvdiffto=prev"
    [CALLBACK, prop, revids, rvdiffto].join("&")
  end

  def vandalism?(tags)
    tags.include?("possible libel or vandalism")
  end

  def load_json(url)
    json = JSON.load(open(url))
  end

end