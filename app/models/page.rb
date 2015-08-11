class Page < ActiveRecord::Base
  has_many :revisions, :dependent => :destroy
  has_many :authors, :through => :revisions
  has_many :categories
  # validates :title, uniqueness: true
  # validates :page_id, uniqueness: true
  WIKI = WikiWrapper.new

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

  def most_recent_vandalism
    revision = WIKI.vandalism(self)
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
    regex.match(most_recent_vandalism.content).to_s.gsub("\"><div>","")
  end

end
