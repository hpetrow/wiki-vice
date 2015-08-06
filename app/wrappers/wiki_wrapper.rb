class WikiWrapper 
  require 'json'
  require 'open-uri'
  
  CALLBACK = "https://en.wikipedia.org/w/api.php?format=json&action=query"

  def get_page(title)
    url = page_revisions_url(title)
    json = JSON.load(open(url))

    if json["continue"].nil?
      rvcontinue = false
    else
      rvcontinue = json["continue"]["rvcontinue"]
    end
    page_id = json["query"]["pages"].keys.first
    page_data = json["query"]["pages"][page_id]
    page = Page.new(title: page_data["title"])
    page.url = page_url(page_data["title"])
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
    json = JSON.load(open(url))
    usercontribs = json["query"]["usercontribs"]
    usercontribs.each do |data|
      page = find_page(data['title'])
      revision = Revision.new(
        {
          revid: data["revid"], 
          time: data["timestamp"], 
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

  private
  def get_more_revisions(params)
    i = 1
    loop do
      url = page_revisions_url(params[:title], {rvcontinue: params[:rvcontinue]})
      json = JSON.load(open(url))
      break if i == params[:continue] || json["continue"].nil?
      page_id = json["query"]["pages"].keys.first
      add_revisions_to_page(params[:page], params[:revisions])  
      i += 1
    end    
  end

  def get_vandalism_revisions(params)
    base_url = build_page_revisions_url(params[:title])
    url = "#{base_url}&rvtag=possible%20libel%20or%20vandalism"
    json = JSON.load(open(url))

    page_id = json["query"]["pages"].keys.first
    revisions = json["query"]["pages"][page_id]["revisions"]
    add_revisions_to_page(params[:page], revisions)
  end

  def page_revisions_url(title, options = {})
    prop = "prop=revisions|categories"
    rvlimit = "rvlimit=50"
    titles = "titles=#{title.gsub(" ", "%20")}"
    rvdiff = "rvdiffto=prev"
    rclimit = "rclimit=10"
    redirects = "redirects"
    rvprop = "rvprop=tags"
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
      if r['diff'].nil?
        content = 'notcached'
      else
        content = r['diff']['*']
      end
      revision = Revision.new(
        time: r['timestamp'], 
        timestamp: r['timestamp'], 
        content: content,
        revid: r['revid'], 
        comment: r['comment'],
        vandalism: vandalism?(r['tags'])
      )

      author = Author.find_or_create_by(name: r['user'])
      revision.author = author
      revision.page = page
      revision.save
    end
  end

  def add_categories_to_page(page, categories)
    categories.each do |c|
      category_name = /^Category:(.+)/.match(c['title'])[1]
      category = Category.create(name: category_name)
      page.categories << category
    end
  end

  def get_user_contributions(author)
    url = user_contribs_url(author)
    json = JSON.load(open(url))

    usercontribs = json["query"]["usercontribs"]
    usercontribs.each do |data|
      page = Page.find_or_create_by(title: data["title"])
      if Revision.find_by(revid: data["revid"])
        revision = Revision.find_by(revid: data["revid"])
      else
        revision = Revision.create(
          time: data["timestamp"],
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

  def find_page(title)
    page = Page.find_by(title: title)
    page = Page.new(title: title) if page.nil?
    page.url = page_url(title)
    page.save
    page
  end

  def vandalism?(tags)
    tags.include?("possible libel or vandalism")
  end
end