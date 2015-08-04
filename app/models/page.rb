class Page < ActiveRecord::Base
  has_many :revisions
  has_many :authors, :through => :revisions

  def top_five_authors
    binding.pry
  end
end
