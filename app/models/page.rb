class Page < ActiveRecord::Base
  has_many :revisions
  has_many :authors, :through => :revisions
  has_many :categories

  def top_five_authors
    results = self.authors.group(:name).order('count_id desc').count('id').max_by(5){|name, num| num}
    results.collect do |r|
      {author: Author.find_by(name: r[0]), count: r[1]}
    end
  end

  def get_date
    DateTime.parse(self.revisions.first.time).to_formatted_s(:long_ordinal)
  end

  def get_anonymous_authors
    self.authors.select do |author|
      author.name.match(/^[0-9 | .]\S*/) ? author : nil
    end
  end

  def get_number_of_anonymous_authors
    self.get_anonymous_authors.count
  end

  def revisions_by_date
    self.revisions.order("DATE(timestamp)").group("DATE(timestamp)").size
  end

  def avg_revisions_per_day
    revisions_by_date.size / revisions.size.to_f
  end

  def friendlier_revisions_per_day
    self.avg_revisions_per_day
  end


  def anonymous_author_location
      self.get_anonymous_authors.collect do |aa| 
        GeoIP.new('lib/assets/GeoIP.dat').country(aa.name)
      end
  end

  def group_anonymous_users_by_location
    locations = self.anonymous_author_location.group_by(&:country_code)
    location_key = {}
    locations.each do |country_code, location|
      location_key[country_code] = location.count
    end
    location_key.sort_by{|code, location_count| location_count}.reverse.to_h
  end

  def find_country_name
    locations = self.anonymous_author_location.collect do |location|
      location.country_name
    end.uniq
  end

end
