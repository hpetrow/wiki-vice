class WikiWrapper 
  require 'json'
  require 'open-uri'
  
  CALLBACK = "https://en.wikipedia.org/w/api.php?format=json&action=query"

  def get_page(title)
    url = build_page_revisions_url(title)
    json = JSON.load(open(url))
    rvcontinue = json["continue"]["rvcontinue"]
    clcontinue = json["continue"]["clcontinue"] 
    page_id = json["query"]["pages"].keys.first
    page_data = json["query"]["pages"][page_id]
    page = Page.new(title: page_data["title"])
    add_categories_to_page(page, page_data["categories"])
    add_revisions_to_page(page, page_data["revisions"])    
    i = 1
    loop do 
      url = build_page_revisions_url(title, {rvcontinue: rvcontinue, clcontinue: clcontinue})
      json = JSON.load(open(url))
      rvcontinue = json["continue"]["rvcontinue"]
      clcontinue = json["continue"]["clcontinue"]       
      page_id = json["query"]["pages"].keys.first
      page_data = json["query"]["pages"][page_id]
      add_categories_to_page(page, page_data["categories"])
      add_revisions_to_page(page, page_data["revisions"])  
      i += 1
      break if i == 5
    end
    page.save
    page
  end

  def build_page_revisions_url(title, options = {})
    prop = "prop=revisions|categories"
    rvlimit = "rvlimit=50"
    titles = "titles=#{title.gsub(" ", "%20")}"
    rvdiff = "rvdiffto=prev"
    url = [CALLBACK, prop, rvlimit, titles, rvdiff]
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
      category = Category.new(name: category_name)
      category.save
      page.categories << category if page.categories.none?{|c| c.name == category.name}
    end
  end

  def get_user_contributions(author)
    url = build_user_contribs_url(author)
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

  def build_user_contribs_url(author)
    list = "list=usercontribs"
    ucuser = "ucuser=#{author.name}"
    uclimit = "uclimit=500"
    ucprop = "ucprop=ids|title|timestamp|comment|size|sizediff|flags|tags"
    ucnamespace = "ucnamespace=0"
    [CALLBACK, list, ucuser, uclimit, ucprop, ucnamespace].join("&")    
  end  


end