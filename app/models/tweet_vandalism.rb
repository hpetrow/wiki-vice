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

  def tweet_suffix
    " ##{page_title.gsub(" ","")}" + " #wikivice"
  end

  def safe_tweet
    self.tweet_parser
  end

  def format_tweet
    self.safe_tweet.slice(0, 128 - tweet_suffix.size) + "..." + tweet_suffix
  end

  def replace_words
    better_words = {
      /fuck/ => "f*ck",
      /rape\w{1}/ => "r****",
      /rape/ => "r***",
      /rapist/ => "r*****",
      /faggots/ => "f****ts",
      /faggot/ => "f****t",
      /cunts/ => "c*nts",
      /cunt/ => "c*nt",
      /niggers/ => "n*****s",
      /nigger/ => "n****"
    }
  end

  def tweet_parser
    test = @content.split(" ")
    test.each do |word|
      self.replace_words.collect do |bad_word, better_word|
        if word.match(bad_word)
          word.replace(better_word)
        else
          word
        end
      end
    end
  end

end


