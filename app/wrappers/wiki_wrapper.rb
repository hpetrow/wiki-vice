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
      get_vandalism_revisions(page)
      page
    else
      "can't find page"
    end
  end

  def get_user_contributions(author)
    url = user_contribs_url(author)
    json = load_json(url)
    persistor = JsonPersistor.new(json)
    persistor.persist_author_revisions(author)
  end

  def get_content_for_revision(revision)
    json = load_json(revision_content_url(revision))
    persistor = JsonPersistor.new(json)
    persistor.persist_revision_content(revision)
  end  

  def get_vandalism_revisions(page)
    json = load_json(vandalism_revisions_url(page))
    persistor = JsonPersistor.new(json)
    persistor.persist_page_revisions(page)
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

  def page_revisions_url(title, options = {})
    prop = "prop=revisions|categories"
    rvlimit = "rvlimit=50"
    titles = "titles=#{title.gsub(" ", "%20")}"
    rvdiff = "rvdiffto=prev"
    rclimit = "rclimit=10"
    rvtag = "&rvtag=possible%20libel%20or%20vandalism"
    rvprop = "rvprop=ids|user|timestamp|comment|tags"
    clprop = "clprop=sortkey|hidden"
    redirects = "redirects"
    url = [CALLBACK, prop, rvlimit, titles, rvdiff, rvprop, clprop,redirects]
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
    ucprop = "ucprop=ids|title|timestamp|comment|size|sizediff|flags|tags"
    ucnamespace = "ucnamespace=0"
    [CALLBACK, list, ucuser, uclimit, ucprop, ucnamespace].join("&")
  end

  def vandalism_revisions_url(page)
    revisions_url = page_revisions_url(page.title)
    url = "#{revisions_url}&rvtag=possible%20libel%20or%20vandalism"
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