class Page < ActiveRecord::Base
  has_many :revisions
  has_many :authors, :through => :revisions

  def top_five_authors
    results = self.authors.group(:name).order('count_id desc').count('id').max_by(5){|name, num| num}
    results.collect do |r|
      {author: Author.find_by(name: r[0]), count: r[1]}
    end
  end

  def get_anonymous_authors
    ip = self.authors.select do |author|
      if author.name.match(/^[0-9 | .]\S*/)
        author
      else
      end
    end
  end
  
end
