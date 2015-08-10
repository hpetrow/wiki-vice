class WikiWrapper
  require 'json'
  require 'open-uri'

  CALLBACK = "https://en.wikipedia.org/w/api.php?format=json&action=query"

  def get_page(title)
    url = page_revisions_url(title)
    json = load_json(url)
    persistor = JsonPersistor.new(json) 
    if persistor.page_exists?
      page = persistor.persist_page
      get_more_revisions(page, json)
      get_vandalism_revisions(page)
      page
    else
      false
    end
  end

  def get_user_contributions(author)
    url = user_contribs_url(author)
    json = load_json(url)
    persistor = JsonPersistor.new(json)
    persistor.persist_author_revisions(author)
  end

  def get_revision_content(revision)
    json = load_json(revision_content_url(revision))
    persistor = JsonPersistor.new(json)
    persistor.persist_revision_content(revision)
  end

  private

  def get_more_revisions(page, json)
    continue = 10
    i = 1
    while (!!json["continue"]["rvcontinue"] && i < continue)
      json = load_json(page_revisions_url(page.title, {rvcontinue: json["continue"]["rvcontinue"]}))
      persistor = JsonPersistor.new(json)
      persistor.persist_page_revisions(page)
      i += 1
    end
  end

  def get_vandalism_revisions(page)
    json = load_json(page_revisions_url(page.title, {rvtag: "possible%20libel%20or%20vandalism"}))
    persistor = JsonPersistor.new(json)
    persistor.persist_page_revisions(page)
  end

  def page_revisions_url(title, options = {})
    prop = "prop=revisions|categories"
    rvlimit = "rvlimit=50"
    titles = "titles=#{title.gsub(" ", "%20")}"
    rvtag = "&rvtag=possible%20libel%20or%20vandalism"
    rvprop = "rvprop=ids|user|timestamp|comment|tags|flags"
    clprop = "clprop=sortkey|hidden"
    redirects = "redirects"
    url = [CALLBACK, prop, rvlimit, titles, rvprop, clprop, redirects]
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
    uclimit = "uclimit=500"
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

end