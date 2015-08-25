class WikiWrapper
  require 'json'
  require 'open-uri'

  CALLBACK = "https://en.wikipedia.org/w/api.php?format=json&action=query"
  def get_title(query)
    url = title_url(query)
    json = load_json(url)
    if valid_page?(json)
      page_id = json["query"]["pages"].keys.first
      page_data = json["query"]["pages"][page_id]
      {page_id: page_id, title: page_data["title"]}
    else
      false
    end
  end

  def get_page(title)
    url = page_revisions_url(title)
    json = load_json(url)
    page_id = json["query"]["pages"].keys.first
    revisions = json["query"]["pages"][page_id]["revisions"]
    paged_revisions(title, json).each do |rev|
      revisions << rev
    end
    revisions
  end

  def get_user_contributions(author)
    url = user_contribs_url(author)
    json = load_json(url)
    json = json["query"]["usercontribs"]
    persistor = JsonPersistor.new(json)
    persistor.insert_pages
    persistor.insert_revisions_into_author(author.id)
  end

  def revision_content(revision)
    json = load_json(revision_content_url(revision))
    page_id = json["query"]["pages"].keys.first.to_s
    revision = json["query"]["pages"][page_id]["revisions"].first
    if revision["texthidden"] 
      content = "text hidden" 
    else
      content = revision["diff"]["*"]
    end
  end

  def recent_changes(num)
    json = load_json(recent_changes_url(num))
    json["query"]["recentchanges"].collect do |rc| 
      {page_id: rc["pageid"], title: rc["title"]}
    end
  end

  def random_page
    json = load_json(random_page_url)
    random = json["query"]["random"].first
    {page_id: random["id"], title: random["title"]}
  end

  def vandalism_revisions(page_title)
    json = load_json(vandalism_url(page_title))
    page_id = json["query"]["pages"].keys.first.to_s
    json["query"]["pages"][page_id]["revisions"]
  end  

  private

  def parse_recent_changes(json)
    json["query"]["recentchanges"]
  end

  def recent_changes_url(num)
    list = "list=recentchanges"
    rcnamespace = "rcnamespace=0"
    rcshow = "rcshow=!minor|!bot"
    rcprop = "rcprop=titles|ids"
    rclimit = "rclimit=#{num}"
    [CALLBACK, list, rcnamespace, rcshow, rclimit].join("&")
  end  

  def random_title(json)
    json["query"]["random"].first["title"]
  end

  def random_page_url
    list = "list=random"
    rnnamespace = "rnnamespace=0"
    [CALLBACK, list, rnnamespace].join("&")
  end

  def paged_revisions(page_title, json)
    continue = 10
    i = 1
    revisions = []
    while ((more_pages?(json) || true) && i < continue)
      parsed_revisions(json).each do |r| revisions << r end
      if more_pages?(json)
        json = load_json(page_revisions_url(page_title, {rvcontinue: json["continue"]["rvcontinue"]}))        
      else
        json = load_json(page_revisions_url(page_title))        
      end
      i += 1
    end
    revisions
  end  


  def parsed_revisions(json)
    page_id = json["query"]["pages"].keys.first.to_s
    json["query"]["pages"][page_id]["revisions"]
  end

  def more_pages?(json)
    !!json["continue"]
  end

  def vandalism_url(title)
    prop = "prop=revisions"
    titles = "titles=#{title}"
    rvlimit = "rvlimit=1"
    rvtag = "rvtag=possible libel or vandalism"
    rvprop = "rvprop=ids|user|timestamp|comment|tags|flags|size"
    rvdiffto ="rvdiffto=prev"
    redirects = "redirects"    
    [CALLBACK, prop, rvprop, rvlimit, rvtag, rvdiffto, redirects, titles].join("&")
  end

  def title_url(query)
    prop = "prop=revisions"
    rvlimit = "rvlimit=1"
    titles = "titles=#{query}"
    rvprop = "rvprop=ids"
    redirects = "redirects"
    [CALLBACK, prop, rvlimit, titles, rvprop, redirects].join("&")
  end

  def page_revisions_url(title, options = {})
    prop = "prop=revisions"
    rvlimit = "rvlimit=50"
    titles = "titles=#{title}"
    rvtag = "&rvtag=possible%20libel%20or%20vandalism"
    rvprop = "rvprop=ids|user|timestamp|comment|tags|flags|size|userid"
    redirects = "redirects"
    url = [CALLBACK, prop, rvlimit, titles, rvprop, redirects]
    if options.empty?
      url.join("&")
    else
      options.each {|key, value| url << "#{key}=#{value}"}
      url.join("&")
    end
  end

  def user_contribs_url(author)
    list = "list=usercontribs"
    ucuser = "ucuser=#{author.name}"
    uclimit = "uclimit=10"
    ucprop = "ucprop=ids|title|timestamp"
    ucshow = "ucshow=!minor"
    ucnamespace = "ucnamespace=0"
    [CALLBACK, list, ucuser, uclimit, ucprop, ucnamespace].join("&")
  end

  def revision_content_url(revision)
    prop = "prop=revisions"
    revids = "revids=#{revision.revid}"
    rvdiffto = "rvdiffto=prev"
    [CALLBACK, prop, revids, rvdiffto].join("&")
  end

  def load_json(url)
    url = URI.escape(url)
    puts "\e[31m#{url}\e[0m"
    json = JSON.load(open(url))
  end 

  def revisions_json(json)
    page_id = json["query"]["pages"].keys.first
    json["query"]["pages"][page_id]["revisions"]
  end

  def valid_page?(json)
    !json["query"]["pages"]["-1"]    
  end

end