class TweetVandalism 
  attr_accessor :content, :client, :page_title, :url

  def initialize(content, page_title, url)
    @content = content
    @client = create_client
    @page_title = page_title
    @url = url
  end

  # tweet parser should check if word exists, if it does, no tweet is sent.

  def create_client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_KEY"]
      config.consumer_secret     = ENV["TWITTER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end

  def send_tweet
    if tweet_okay?
      client.update(format_tweet)
    end
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
      /fucked/i => "f*cked",
      /fuck/i => "f*ck",
      /rape\w{1}/i => "r****",
      /rape/i => "r***",
      /rapist/i => "r*****",
      /faggot/i => "f*****s",
      /[f][a][g][g][o][t]/i => "f****t",
      /[c][u][n][t][s]/i => "c*nts",
      /[c][u][n][t]/i => "c*nt",
      /[n][i][g][g][e][r][s]/i => "n*****s",
      /n[i][g][g][e][r]/i => "n****"
    }
  end

  def tweet_okay?
    okay = true
    banned_words = /fuck|cunt|rape|rapist|nigger/
    if @content.match(banned_words)
      okay = false
    end
    okay 
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
    end.join(" ")
  end

end


