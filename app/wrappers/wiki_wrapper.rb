class WikiWrapper 
  attr_accessor :callback, :format, :action, :prop, :pclimit, :titles

  def initialize
    @callback = "https://en.wikipedia.org/w/api.php?"
    @format = "json"
    @action = "query"
    @pclimit = "500"
  end

  
end