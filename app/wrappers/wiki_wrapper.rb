class WikiWrapper 
  require 'json'
  require 'open-uri'
  

  attr_accessor :callback, :format, :action, :prop, :rvlimit, :titles

  def initialize
    @callback = "https://en.wikipedia.org/w/api.php?"
    @format = "format=json"
    @action = "action=query"
    @rvlimit = "rvlimit=500"
    @prop = "prop=revisions"
  end

  def get_json(title, options={}) 
    self.titles = "titles=#{title.gsub(" ", "%20")}"
    url = "#{@callback}&#{@format}&#{@action}&#{@prop}&#{@rvlimit}&#{self.titles}&rvdiffto=prev"
    if options[:rvcontinue] 
      url += "&rvcontinue=#{options[:rvcontinue]}"
    end
    html = open(url)
    JSON.load(html)
  end

  def get_page(title)
    json = get_json(title)
    rvcontinue = json["continue"]["rvcontinue"]
    page_id = json["query"]["pages"].keys.first
    query = json["query"]["pages"][page_id]
    page = Page.new(title: query["title"])
    revisions = query["revisions"]
    add_revisions_to_page(page, revisions)

    1.times do |i|
      json = get_json(title, {rvcontinue: rvcontinue})
      rvcontinue = json["continue"]["rvcontinue"]
      page_id = json["query"]["pages"].keys.first
      query = json["query"]["pages"][page_id]
      page = Page.new(title: query["title"])
      revisions = query["revisions"]
      add_revisions_to_page(page, revisions)
      page.save
    end
    page
  end

  def add_revisions_to_page(page, revisions)
    revisions.each do |r|
      author = Author.find_or_create_by(name: r['user'])
      timestamp = r['timestamp']
      revid = r['revid']
      comment = r['comment']
      content = r['diff']['*'] || 'notcached'
      revision = Revision.new(time: timestamp, content: content, revid: revid, author_id: author.id)
      page.revisions << revision
      revision.save
    end

  end

  def get_user_contributions(username)
    list = "list=usercontribs"
    ucuser = "ucuser=#{username}"
    uclimit = "uclimit=500"
    ucprop = "ucprop=ids|title|timestamp|comment|size|sizediff|flags|tags"
    url = [self.callback, self.action, self.format, list, ucuser, uclimit, ucprop].join("&")
    html = open(url)
    json = JSON.load(html)
    usercontribs = json["query"]["usercontribs"]

    usercontribs.each do |data|
      page = Page.find_or_create_by(title: data["title"])
      revid = data["revid"]
      timestamp = data["timestamp"]
      comment = data["comment"]
    end
  end

end