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

    9.times do |i|
      json = get_json(title, {rvcontinue: rvcontinue})
      rvcontinue = json["continue"]["rvcontinue"]
      page_id = json["query"]["pages"].keys.first
      query = json["query"]["pages"][page_id]
      page = Page.new(title: query["title"])
      revisions = query["revisions"]
      add_revisions_to_page(page, revisions)
    end
  end

  def add_revisions_to_page(page, revisions)
    revisions.each do |r|
      author = Author.new(name: r['user']).save
      timestamp = r['timestamp']
      comment = r['comment']
      content = r['diff']['*']
      revision = Revision.new(time: timestamp, content: content)
      revision.save
      page.revisions << revision
    end

  end

end