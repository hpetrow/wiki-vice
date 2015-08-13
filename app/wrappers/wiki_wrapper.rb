class WikiWrapper
  require 'json'
  require 'open-uri'

  CALLBACK = "https://en.wikipedia.org/w/api.php?format=json&action=query"

  def get_page(title)
    url = page_revisions_url(title)
    json = load_json(url)
    persistor = JsonPersistor.new(json)   
    if valid_page?(json)
      page = persistor.insert_page
      title = page.title
      id = page.id
      revisions = paged_revisions(title, json)

      persistor.json = revisions
      persistor.insert_authors
      persistor.insert_revisions_into_page(id)
      persistor.json = vandalism_revisions(title)
      persistor.insert_revisions_into_page(id) if !(persistor.json.nil?)
      page
    else
      false
    end
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

  private

  def paged_revisions(page_title, json)
    continue = 14
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
    titles = "titles=#{title.gsub(" ", "%20")}"
    rvlimit = "rvlimit=1"
    rvtag = "rvtag=possible%20libel%20or%20vandalism"
    rvprop = "rvprop=ids|user|timestamp|comment|tags|flags|size"
    rvdiffto ="rvdiffto=prev"
    redirects = "redirects"    
    [CALLBACK, prop, rvprop, rvlimit, rvtag, rvdiffto, redirects, titles].join("&")
  end

  def vandalism_revisions(page_title)
    json = load_json(vandalism_url(page_title))
    page_id = json["query"]["pages"].keys.first.to_s
    json["query"]["pages"][page_id]["revisions"]
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
    json["query"]["pages"]["-1"].nil?    
  end

end