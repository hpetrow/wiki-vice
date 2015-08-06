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

  def get_revision_content(revision)
    url = revision_content_url(revision)
    json = JSON.load(open(url))
    binding.pry
    revisions = json["query"]["pages"][revision.page.id]["revisions"]

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

  def page_revisions_url(title, options = {})
    prop = "prop=revisions|categories"
    rvlimit = "rvlimit=50"
    titles = "titles=#{title.gsub(" ", "%20")}"
    rvdiff = "rvdiffto=prev"
    rclimit = "rclimit=10"
    redirects = "redirects"
    url = [CALLBACK, prop, rvlimit, titles, rvdiff, redirects]
    if options.empty?
      url.join("&")
    else
      options.each {|key, value| url << "#{key}=#{value}"}
      url.join("&")
    end
  end

  def add_revisions_to_page(page, revisions)
    revisions.each do |r|
      puts r['revid']
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
        comment: r['comment']
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
    rvprop = "rvprop=content"
    [CALLBACK, prop, revids, rvprop].join("&")
  end

  def find_page(title)
    page = Page.find_by(title: title)
    page = Page.new(title: title) if page.nil?
    page.url = page_url(title)
    page.save
    page
  end



end