class Vandalism
  include Findable::InstanceMethods

####################### CLASS METHODS #################

  # Class method: find all pages that include vandalism.
  def self.all_pages_with_vandalism
    Page.includes(:revisions).where(revisions: {vandalism: true}).select(:title)
  end

  #Class method: For each page with vandalism, 
  #find which pages have the most instances
  def self.pages_with_most_vandalism
    self.all_pages_with_vandalism.group(:title).count(:title)
    .sort_by{|title, count| count}.reverse
  end

  # Class method: Get all vandalism authors
  def self.get_all_vandalism_authors
    Author.includes(:revisions).where(revisions: {vandalism: true})
  end

  # Returns the most common vandalizers
  def self.the_usual_suspects
    get_all_vandalism_authors.group(:name).count(:name).sort_by{|name, count| count}.reverse.to_h
  end

####################### PAGE METHODS #################
  #Given a page, find all instances of vandalism on that page.
  def find_all_vandalism_for_page(page)
    Revision.where(vandalism: true, page_id: page.id)
  end

  # Most recent vandalism for page
  def most_recent_page_vandalism(page)
    self.find_all_vandalism_for_page(page).first
  end

  def most_recent_vandalism_content(page)
    regex = /(?<=diff-addedline).+?(?=<\/)/
    content = self.most_recent_page_vandalism(page)
    reg_content = regex.match(content).to_s.gsub("\"><div>","")
  end

  #Given a page, get all vandalism authors for a page
  def get_vandalism_authors_for_page(page)
    Author.includes(:revisions, :pages).where(anonymous: true, revisions: {vandalism: true, page_id: page.id})
  end

#################### REVISION METHODS #################

  # Given a revision, parse that revision so humans can read it
  def vandalism_regex(content)
    regex = /(?<=diff-addedline).+?(?=<\/)/
    regex.match(content).to_s.gsub("\"><div>","")
  end


  #Given revision, find its author
  def find_author(revision)
    author = Author.find_by(revision.author_id)
  end

#################### ANONYMOUS METHODS #################

  #Find all anonymous authors with vandalism content
  def get_anon_authors
    Author.includes(:revisions).where(anonymous: true, revisions: {vandalism: true}).select(:name, :id) #add join to vandalism here
  end

  #Get the ip addresses from anonymous 
  def get_ips_from_anon_authors
    self.get_anon_authors.select(:name)
  end

  def countries_with_most_anon_authors
    counted_countries = {}
    self.get_location_of_anon_authors.group_by(&:country_name).map{|country, counter|
      counted_countries[:name] = country,
      counted_countries[:count] = counter.count 
    }.to_h.sort_by{|country, count| count}.reverse
  end

  def get_country_for_anonymous_authors(author_collection)
    author_collection = self.get_anon_authors
    self.get_geoip_location(author_collection)
  end

  # def self.the_usual_suspects_by_country_anonymous
  # end

  # def self.the_usual_suspects_by_country
  #   get_anon_authors.group(:name).count(:name)
  # end

end