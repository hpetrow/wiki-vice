class Author < ActiveRecord::Base
  has_many :revisions
  has_many :pages, :through => :revisions
  WIKI = WikiWrapper.new

  def top_contributions
    # Returns the pages that the author has contributed to the most
    # and the amount of contributions he has made to that page
    WIKI.get_user_contributions(self) if self.unique_pages.size == 1
    contribs = self.pages.group(:title).order('count_id desc').count('id').max_by(5){|name, num| num}
  end

  def get_user_contributions_wiki
    WIKI.get_user_contributions(self) if self.unique_pages.size == 1
  end

  def get_user_comments
    user_contribs = []
    self.get_user_contributions_wiki.take(50).each do |contribution|
      binding.pry
      if !contribution["comment"].nil?
        user_contribs << contribution["comment"].gsub("/* ","").gsub("*/ ","").gsub("--", "") # add in some regex love here
      end
    end
    user_contribs.collect{|comment| comment.split(" ") }.flatten.sort
  end

  def count_comment_words
    counted_words = {}
    self.get_user_comments.reduce(counted_words) { |h, v| 
      h.store(v, h[v] + 1); h }
      .sort_by{|k,v| v }.reverse.to_h
  end

  def ignore_dumb_comment_words
    Regexp.new('to' 'and' 'the' 'on' 'in' 'of', true)
    self.count_comment_words
  end
    #look through all words in comments
    #look for matching words
    #count how many times repeat terms occur
    #.sort
    #Ignore dumb words like to/and/the/in/on/of/--/
    #Return a list of most used terms with how many times they occur


  def most_recent_revision
    revision = self.revisions.order("timestamp desc").limit(1).first
    if revision.content.nil?
      WIKI.get_revision_content(revision)
    end
    revision
  end

  def unique_pages
    self.pages.uniq
  end

end
