class Vandalism
  attr_accessor:

  def initialize
  end

  def get_authors
  end

  def get_content
  end

  def get_anon_authors
    Author.where(anonymous: true)
  end

  def get_ips_from_anon_authors
    Author.where(anonymous: true).select(:name)
  end

  def get_location_of_anon_authors
  end

  def most_anon_authors_country
  end

  def the_usual_suspects
  end


#  Already in there:

#JSON Persistor:
# private

#   def ip_address?(name)
#     !!(/\d{4}:\d{4}:\w{4}:\d{4}:\w{4}:\w{4}:\w{3}:\w{4}|\d{2,3}\.\d{2,3}\.\d{2,3}\.\d{2,3}/.match(name)) 
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