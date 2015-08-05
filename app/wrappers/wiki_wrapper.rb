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
      page
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
      revision = Revision.new(time: timestamp, timestamp: timestamp, content: content, revid: revid, author_id: author.id)
      page.revisions << revision
      revision.save
    end

  end

  def get_user_contributions(author)
    list = "list=usercontribs"
    ucuser = "ucuser=#{author.name}"
    uclimit = "uclimit=500"
    ucprop = "ucprop=ids|title|timestamp|comment|size|sizediff|flags|tags"
    ucnamespace = "ucnamespace=0"
    url = [self.callback, self.action, self.format, list, ucuser, uclimit, ucprop, ucnamespace].join("&")
    html = open(url)
    json = JSON.load(html)
    usercontribs = json["query"]["usercontribs"]

    usercontribs.each do |data|
      page = Page.find_or_create_by(title: data["title"])
      revision = Revision.find_or_create_by(revid: data["revid"])
      revision.time = data["timestamp"]
      revision.timestamp = data["timestamp"]
      revision.size = data["size"]
      revision.size_diff = data["sizediff"]
      revision.page = page
      revision.author = author
      revision.save
    end

  end

end