class TweetVandalism 
  attr_accessor :content, :client, :page_title, :url

  def initialize(content, page_title, url)
    @content = content
    @client = create_client
    @page_title = page_title
    @url = url
  end

  def create_client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_KEY"]
      config.consumer_secret     = ENV["TWITTER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end

  def send_tweet
    client.update(format_tweet)
  end

  def format_tweet
    content.slice(0, 80) + "..." + "from #{page_title}" + " #wikivice" + " wikivice.herokuapp.com" + url
  end

end


