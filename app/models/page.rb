class Page < ActiveRecord::Base
  has_many :revisions
  has_many :authors, :through => :revisions

  def top_five_authors
    self.authors.group(:name).order('count_id desc').count('id').max_by(5){|id, num| num}
  end

  def find_author_by_name(author_name)
    self.authors.find_by(name: author_name)
  end


  
end
