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
    WIKI.get_user_contributions(self).take(50).each do |contribution|
      #user_contribs[:size_diff] = contribution["sizediff"]
      user_contribs << contribution["comment"].gsub("/* ","").gsub("*/ ","")
    end
    
    split_words = user_contribs.collect  do |comment|
      comment.split(" ")
    end
    split_words.compact
    #look through all words in comments
    #look for matching words
    #count how many times repeat terms occur
    #Return a list of most used terms with how many times they occur


  end


  def most_recent_revision
    self.revisions.order("timestamp desc").limit(1).first
  end

  def unique_pages
    self.pages.uniq
  end

end
