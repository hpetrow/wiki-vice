class WikiWrapper
  require 'json'
  require 'open-uri'

  CALLBACK = "https://en.wikipedia.org/w/api.php?format=json&action=query"

  def get_page(title)
    url = page_revisions_url(title)
    json = load_json(url)
    persistor = JsonPersistor.new(json) 
    if json["query"]["pages"]["-1"].nil?
      page = persistor.insert_page
      revisions = json["query"]["pages"][page.page_id.to_s]["revisions"]
      revisions << get_more_revisions(page, json)
      persistor.json = revisions.flatten
      persistor.insert_authors
      persistor.insert_revisions(page)
      persistor.json = get_vandalism_revisions(page)
      persistor.persist_page_revisions(page) if !(persistor.json.nil?)
      page
    else
      false
    end
  end

  def most_recent_vandalism(page)
    json = load_json(vandalism_url(page.title))
    json = json["query"]["pages"][page.page_id.to_s]["revisions"].first
    persistor = JsonPersistor.new(json)
    persistor.insert_vandalism(page)
  end  

  def get_user_contributions(author)
    url = user_contribs_url(author)
    json = load_json(url)
    persistor = JsonPersistor.new(json)
    persistor.persist_author_revisions(author)
  end

  def revision_content(revision)
    json = load_json(revision_content_url(revision))
    page_id = Page.joins(:revisions).where(revisions: {revid: revision.revid}).take.page_id
    revision = json["query"]["pages"][page_id.to_s]["revisions"].first
    content = revision["diff"]["*"]
  end

  private

  def get_more_revisions(page, json)
    continue = 10
    i = 1
    revisions = []
    while (!!json["continue"] && i < continue)
      json = load_json(page_revisions_url(page.title, {rvcontinue: json["continue"]["rvcontinue"]}))
      revisions << json["query"]["pages"][page.page_id.to_s]["revisions"]
      i += 1
    end
    revisions.flatten
  end  

  def vandalism_url(title)
    prop = "prop=revisions"
    titles = "titles=#{title.gsub(" ", "%20")}"
    rvlimit = "rvlimit=1"
    rvtag = "rvtag=possible%20libel%20or%20vandalism"
    rvprop = "rvprop=ids|user|timestamp|comment|tags|flags|size"
    rvdiffto ="rvdiffto=prev"
    redirects = "redirects"    
    [CALLBACK, prop, titles, rvprop, rvlimit, rvtag, rvdiffto, redirects].join("&")
  end

  def get_vandalism_revisions(page)
    json = load_json(page_revisions_url(page.title, {rvtag: "possible%20libel%20or%20vandalism"}))
  end

  def page_revisions_url(title, options = {})
    prop = "prop=revisions"
    rvlimit = "rvlimit=50"
    titles = "titles=#{title.gsub(" ", "%20")}"
    rvtag = "&rvtag=possible%20libel%20or%20vandalism"
    rvprop = "rvprop=ids|user|timestamp|comment|tags|flags|size"
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

  def page_url(title)
    "https://en.wikipedia.org/wiki/" + title.gsub(" ", "_")
  end

  def revision_content_url(revision)
    prop = "prop=revisions"
    revids = "revids=#{revision.revid}"
    rvdiffto = "rvdiffto=prev"
    [CALLBACK, prop, revids, rvdiffto].join("&")
  end

  def load_json(url)
    json = JSON.load(open(url))
  end

  def ip_address?(name)
    /\d{4}:\d{4}:\w{4}:\d{4}:\w{4}:\w{4}:\w{3}:\w{4}|\d{2,3}\.\d{2,3}\.\d{2,3}\.\d{2,3}/.match(name)    
  end  

end