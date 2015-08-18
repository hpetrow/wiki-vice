class Author < ActiveRecord::Base
  has_many :revisions
  has_many :pages, :through => :revisions
  WIKI = WikiWrapper.new

  def top_contributions
    # Returns the pages that the author has contributed to the most
    # and the amount of contributions he has made to that page
    WIKI.get_user_contributions(self)
    Revision.includes(:author, :page).where(authors: {id: self.id}).group(:title).order("count_id DESC").count.take(5)
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

  def most_recent_revision
    self.revisions.order("timestamp desc").limit(1).first
  end

  def unique_pages
    self.pages.uniq
  end

  def display_name
    self.anonymous ? 'Anonymous' : self.name
  end

end
