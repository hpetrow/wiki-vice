class Author < ActiveRecord::Base
  has_many :revisions
  has_many :pages, :through => :revisions

  def top_contributions
    # Returns the pages that the author has contributed to the most
    # and the amount of contributions he has made to that page
    w = WikiWrapper.new
    contributions = w.get_user_contributions(self)
    self.pages.group(:title).order('count_id desc').count('id').max_by(5){|name, num| num}
  end

  def most_recent_revision
    binding.pry
  end

end
