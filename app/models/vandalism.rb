class Vandalism
  #include ActiveModel::Model
  # belongs_to :author, :page, :revision
  # Table: author_id, page_id
          # anon_authors, content

  # attr_accessor:

  def initialize
  end

  def find_vandalism_for_page(page)
    #for console testing: page = Page.find(1)
    Revision.where(vandalism: true, page_id: page.id).select(:content)

  end



  def self.all_pages_with_vandalism
    Page.includes(:revisions).where(revisions: {vandalism: true}).select(:title)
  end

  def self.pages_with_most_vandalism

  end

  def self.get_all_vandalism_authors
    Author.includes(:revisions).where(revision)
  end

  def get_vandalism_authors_for_page
  end

  def find_author(revision)
    author = Author.find_by(revision.author_id)
  end

  def get_content
    Revision.where(vandalism: true)
    author = Author.find_by(revision.author_id)
    #go through parser
    #where(revisions: :author_id, authors: :id)
  end

  def get_anon_authors
    Author.includes(:revisions).where(anonymous: true, revisions: {vandalism: true}).select(:name, :id) #add join to vandalism here
  end

  def get_ips_from_anon_authors
    self.get_anon_authors.select(:name)
  end

  def join_content_with_ips
    # Author.where(anonymous: true).select(:name, :id)
    # .includes(:revisions).where(anonymous: true, revisions: {vandalism: true, author_id: ?})
  end

  def get_location_of_anon_authors
    self.get_anon_authors.collect do |aa| 
        begin
          GeoIP.new('lib/assets/GeoIP.dat').country(aa.name)
        rescue Exception => e
          puts e
        end
      end
  end

  def most_anon_authors_country
    counted_countries = {}
    self.get_location_of_anon_authors.group_by(&:country_name).map{|country, counter|
      counted_countries[:name] = country,
      counted_countries[:count] = counter.count 
    }.to_h.sort_by{|country, count| count}.reverse
  end

  def the_usual_suspects_anonymous
    self.get_ips_from_anon_authors.group(:name).count(:name)
    .to_h.sort_by{|ip, count| count}.reverse
  end

  def the_usual_suspects_by_country_anonymous

  end

  def the_usual_suspects_by_country
    self.get_anon_authors.group(:name).count(:name)
  end


#  Already in there:

#JSON Persistor:
# private

#   def ip_address?(name)
     #regex = /\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}|\d{2,3}\.\d{2,3}\.\d{2,3}\.\d{2,3}/
#     !!(regex.match(name)) 
#   end

#   def vandalism?(tags)
#     tags.include?("possible libel or vandalism")
#   end

# WikiWrapper

# def insert_vandalism(page)
#     author = Author.find_or_create_by(name: json["user"])
#     Revision.create(revid: json["revid"], timestamp: json["timestamp"], page_id: page.id)
#   end


# def insert_revisions_into_page(page_id)
#     values = []
#     json.each do |r|
#       if !(r["minor"]) && !(r["bot"]) && r["user"]
#         vandalism = vandalism?(r["tags"])  ########
#         author = Author.find_or_create_by(name: r["user"])
#         values << [r['revid'], r["timestamp"], vandalism, page_id, author.id]
#       end
#     end
#     columns = [:revid, :timestamp, :vandalism, :page_id, :author_id]
#     Revision.import(columns, values)    
#   end

# private

# def vandalism_url(title)
#     prop = "prop=revisions"
#     titles = "titles=#{title.gsub(" ", "%20")}"
#     rvlimit = "rvlimit=1"
#     rvtag = "rvtag=possible%20libel%20or%20vandalism"
#     rvprop = "rvprop=ids|user|timestamp|comment|tags|flags|size"
#     rvdiffto ="rvdiffto=prev"
#     redirects = "redirects"    
#     [CALLBACK, prop, titles, rvprop, rvlimit, rvtag, rvdiffto, redirects].join("&")
#   end

# def vandalism_revisions(page_title)
#     json = load_json(vandalism_url(page_title))
#     page_id = json["query"]["pages"].keys.first.to_s
#     json["query"]["pages"][page_id]["revisions"]
#   end




end