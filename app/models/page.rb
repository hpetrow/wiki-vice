class Page < ActiveRecord::Base
  has_many :revisions, :dependent => :destroy
  has_many :authors, :through => :revisions
  has_many :categories
  validates :title, uniqueness: true
  validates :page_id, uniqueness: true
  WIKI = WikiWrapper.new
  BAD_IPS = ["223.176.156.214"]

  def top_five_authors
    results = self.authors.group(:name).order('count_id desc').count('id').max_by(5){|name, num| num}
    results.collect do |r|
      {author: Author.find_by(name: r[0]), count: r[1]}
    end
  end

  def get_date
    !!self.revisions.first.timestamp ? self.revisions.first.timestamp.to_formatted_s(:long_ordinal) : 'not available'
  end

  def get_anonymous_authors
    self.authors.select do |author|
      author.name.match(/\d{4}:\d{4}:\w{4}:\d{4}:\w{4}:\w{4}:\w{3}:\w{4}|\d{2,3}\.\d{2,3}\.\d{2,3}\.\d{2,3}/)
    end
  end

  def get_number_of_anonymous_authors
    self.get_anonymous_authors.count
  end

  def days_between_revisions
    revisions_ordered = self.revisions.order("DATE(timestamp)")
    first_date = revisions_ordered.first.timestamp.to_date
    last_date = revisions_ordered.last.timestamp.to_date
    ((last_date - first_date).to_f / revisions.size).round
  end

  def anonymous_author_location
      self.get_anonymous_authors.collect do |aa| 
        begin
          GeoIP.new('lib/assets/GeoIP.dat').country(aa.name)
        rescue Exception => e
          puts e
        end
      end.compact
  end

  def anonymous_location_for_map
    locations = self.anonymous_author_location.group_by(&:country_code2)
    location_key = {}
    locations.each do |country_code, location|
      location_key[country_code] = location.count
    end
    location_key.sort_by{|code, location_count| location_count}.reverse.to_h
  end

    def anonymous_location_for_view
    locations = self.anonymous_author_location.group_by(&:country_name)
    location_key = {}
    locations.each do |country_code, location|
      location_key[country_code] = location.count
    end
    location_key.sort_by{|code, location_count| location_count}.reverse.to_h.first(5)
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

  def unique_authors
    self.authors.uniq
  end

  def latest_revision
    first_revision = self.revisions.first
    if first_revision.content.nil?
      WIKI.get_revision_content(first_revision)
    end
    first_revision
  end

  def wiki_link
    url = "https://en.wikipedia.org/wiki/" + self.title.gsub(" ", "_")
  end

  def most_recent_vandalism
    self.revisions.where("vandalism = ?", true).order("timestamp desc").limit(1).first
  end

  def most_recent_vandalism_content
    vandalism = self.most_recent_vandalism
    if vandalism 
      vandalism.content = WIKI.get_revision_content(vandalism)
      vandalism.content.html_safe
    else
      ""
    end
  end

  def most_recent_vandalism_regex
    regex = /(?<=diff-addedline).+?(?=<\/)/
    regex.match(most_recent_vandalism_content).to_s.gsub("\"><div>","")
  end

  def get_unique_dates
    all_dates = self.revisions.pluck(:timestamp)
    all_dates.collect do |datetime|
      datetime
    end.uniq
  end

  def get_dates
    all_dates = self.revisions.pluck(:timestamp)
  end

  def count_revs_per_day
    counted_revs = {}
    self.get_dates.inject(Hash.new(0)) {|h,v|
      date = v.strftime("%F");
      date = (h[date] += 1) ; h }.sort_by{|k,v| k
    }.reverse.to_h
  end

  def format_rev_dates_for_c3
    self.count_revs_per_day.collect do |date, count|
      date 
    end.unshift('x')
  end

  def format_rev_counts_for_c3
    self.count_revs_per_day.collect do |date, count|
      count
    end.unshift('Revisions Per Day')
  end

end
