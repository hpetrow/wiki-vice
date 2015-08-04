class Author < ActiveRecord::Base
  has_many :revisions
  has_many :pages, :through => :revisions

  def top_contributions
    # Returns the pages that the author has contributed to the most
    # and the amount of contributions he has made to that page
    w = WikiWrapper.new
    contributions = w.get_user_contributions(self)
    binding.pry
  end
end
