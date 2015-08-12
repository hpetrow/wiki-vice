class Page < ActiveRecord::Base
  has_many :revisions, :dependent => :destroy
  has_many :authors, :through => :revisions
  has_many :categories
  validates :title, uniqueness: true
  validates :page_id, uniqueness: true
  WIKI = WikiWrapper.new

  def top_revisions
    max = self.revisions.size >= 5 ? 5 : revisions.length
    self.revisions.slice(0, max).each { |revision|
      revision.with_content
    }
  end

  def top_five_authors
    results =  Revision.includes(:page, :author).where(pages: {id: self.id}).group(:name).order("count_id DESC").count.take(5)
    results.collect do |r|
      {author: Author.where(authors: {name: r[0]}).take, count: r[1]}
    end
  end

  def get_date
    Page.includes(:revisions).where(pages: {id: p.id}).take.timestamp
  end

  def get_anonymous_authors
    Author.includes(:pages).where(pages: {id: self.id}, authors: {anonymous: true})
  end

  def get_number_of_anonymous_authors
    self.get_anonymous_authors.count
  end

  def days_between_revisions
    first_date = Revision.includes(:page).where(pages: {id: self.id}).order(timestamp: :asc).take.timestamp
    last_date = Revision.includes(:page).where(pages: {id: self.id}).order(timestamp: :desc).take.timestamp
    ((last_date.to_date - first_date.to_date).to_f / revisions.size).round
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
    Author.includes(:page).where(pages: {id: self.id}).distinct
  end

  def latest_revision
    first_revision = Revision.includes(:page).where(pages: {id: self.id}).take
    if first_revision.content.nil?
      WIKI.get_revision_content(first_revision)
    end
    first_revision
  end

  def wiki_link
    url = "https://en.wikipedia.org/wiki/" + self.title.gsub(" ", "_")
  end

  def wiki_vice_link
    url = "/pages/#{self.id}"
  end

  def most_recent_vandalism
    vandalism = self.revisions.where('vandalism = ?', true).first
    vandalism.with_content if !!vandalism
  end

  def get_dates
    self.revisions.pluck(:timestamp)
  end

  def group_timestamps_by_date
    self.get_dates.group_by{|timestamp| timestamp.to_date }
  end

  def group_and_count_revs_per_day
    counted_revisions = {}
    self.group_timestamps_by_date.map {|timestamp, counter| 
        counted_revisions[:date] = timestamp.strftime("%F"),
        counted_revisions[:count] = counter.count
      }.to_h
  end

  def format_rev_dates_for_c3
    self.group_and_count_revs_per_day.collect do |date, count|
      date 
    end.unshift('x')
  end

  def format_rev_counts_for_c3
    self.group_and_count_revs_per_day.collect do |date, count|
      count
    end.unshift('Revisions Per Day')
  end

  def edit_activity_amount
    case self.days_between_revisions
    when (0..5)
      "highly active"
    when (5..15)
      "moderately active"
    else 
      "relatively stable"
    end
  end

  def get_photo(title)
    search = Google::Search::Image.new(:query => title, :image_size => :medium)
    search.first.uri
  end

  def new_vandalism
    if self.most_recent_vandalism && self.most_recent_vandalism.created_at > DateTime.now - 3.minutes
      @twitter = TweetVandalism.new("content test")
      binding.pry
      @twitter.client.update(self.most_recent_vandalism_regex.slice(0, 100) + "##{self.title}" + " #wikivice")
    end
  end


end


