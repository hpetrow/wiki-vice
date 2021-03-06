class Page < ActiveRecord::Base
  has_many :revisions, :dependent => :destroy
  has_many :authors, :through => :revisions
  has_many :categories
  validates :title, uniqueness: true
  validates :page_id, uniqueness: true
  WIKI = WikiWrapper.new
  include Findable::InstanceMethods

  def top_revisions
    max = self.revisions.size >= 5 ? 5 : revisions.length
    self.revisions.slice(0, max)
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

  def revision_rate
    if self.revisions.size > 0
      first_date = Revision.includes(:page).where(pages: {id: self.id}).order(timestamp: :asc).take.timestamp
      last_date = Revision.includes(:page).where(pages: {id: self.id}).order(timestamp: :desc).take.timestamp
      rate = ((last_date.to_date - first_date.to_date).to_f / revisions.size)
    end
  end

  def time_between_revisions
    if self.revisions.size > 0
      time = revision_rate
      if time >= 1
        time = time.round
        period = "day".pluralize(time)
        "#{time} #{period}"
      elsif (time * 24) < 1
        time = ((time * 24) * 60).round
        period = "minute".pluralize(time)
        "#{time} #{period}"
      else
        time = (time * 24).round
        period = "hour".pluralize(time)
        "<span class='timer' data-from='0' data-to='#{time}' data-speed='2500'></span> #{period}".html_safe
      end
    end
  end

  def unique_authors
    binding.pry
    self.authors.uniq.count
  end

  def anonymous_author_location
    author_collection = self.get_anonymous_authors
    self.get_geoip_location(author_collection)
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

  def wiki_link
    url = "https://en.wikipedia.org/wiki/" + self.title.gsub(" ", "_")
  end

  def wiki_vice_link
    url = "/pages/#{self.id}"
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
    if self.authors.count > 10
      case revision_rate
      when (0...2)
        "highly active"
      when (2...15)
        "moderately active"
      else 
        "relatively stable"
      end
    else
      "not active"
    end
  end

  def most_recent_vandalism
    vandalism = Vandalism.new 
    vandalism.most_recent_page_vandalism(self)
  end

  def new_vandalism
    if self.most_recent_vandalism && self.most_recent_vandalism.created_at > DateTime.now - 3.minutes
      @twitter = TweetVandalism.new(self.most_recent_vandalism.parse_diff_content, self.title, wiki_vice_link)
      @twitter.send_tweet
    end
  end

  def author_count
    Author.includes(:pages).where(pages: {id: self.id}).count
  end
end
