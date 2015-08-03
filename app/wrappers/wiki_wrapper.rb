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

  def get_json(title) 
    self.titles = "titles=#{title.gsub(" ", "%20")}"
    url = "#{@callback}&#{@format}&#{@action}&#{@prop}&#{@rvlimit}&#{self.titles}&rvdiffto=prev"
    html = open(url)
    JSON.load(html)
  end

  def get_page(title)
    json = get_json(title)
    page_id = json["query"]["pages"].keys.first
    query = json["query"]["pages"][page_id]
    page = Page.new(title: query["title"])
    
  end

  def add_revisions_to_page(revisions)


  end

end