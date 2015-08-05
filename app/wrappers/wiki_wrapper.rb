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

    if Page.find_by(title: page_data["title"])
      page = Page.find_by(title: page_data["title"])
    else 
      page = Page.new(title: page_data["title"])
      add_categories_to_page(page, page_data["categories"])
      add_revisions_to_page(page, page_data["revisions"])    
      i = 1
      loop do 
        url = build_page_revisions_url(title, {rvcontinue: rvcontinue, clcontinue: clcontinue})
        page_id = json["query"]["pages"].keys.first
        page_data = json["query"]["pages"][page_id]
        add_categories_to_page(page, page_data["categories"])
        add_revisions_to_page(page, page_data["revisions"])  
        i += 1
        break if i == 2
      end
      page
    end
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
      revision = Revision.new(
        time: r['timestamp'], 
        timestamp: r['timestamp'], 
        content: r['diff']['*'] || 'notcached', 
        revid: r['revid'], 
        comment: r['comment']
        )
      revision.author = Author.find_or_create_by(name: r['user'])
      revision.page = page
    end
  end

  def add_categories_to_page(page, categories)
    categories.each do |c|
      category = /^Category:(.+)/.match(c['title'])[1]
      page.categories << Category.find_or_create_by(name: category) if page.categories.none?{|c| c.name == category}
      page.save
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
        Revision.new(
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
    [CALLBACK, FORMAT, ACTION, list, ucuser, uclimit, ucprop, ucnamespace].join("&")    
  end  


end