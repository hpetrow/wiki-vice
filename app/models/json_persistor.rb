class JsonPersistor
  attr_accessor :json

  def initialize(json)
    @json = json
  end

  def insert_page
    page_id = json["query"]["pages"].keys.first
    page_data = json["query"]["pages"][page_id]
    Page.find_or_create_by(page_id: page_id, title: page_data["title"])
  end

  def insert_authors
    values = []
    json.each do |r|
      if r["user"]
        author_name = r["user"]
        ip_address?(author_name) ? anonymous = true : anonymous = false
        values << [author_name, anonymous]
      end
    end
    columns = [:name, :anonymous]
    Author.import(columns, values)   
  end  

  def insert_pages
    values = []
    json.each do |data|
      values << [data["pageid"], data["title"]]
    end
    columns = [:page_id, :title]
    Page.import(columns, values)
  end

  def insert_vandalism(page)
    author = Author.find_or_create_by(name: json["user"])
    Revision.create(revid: json["revid"], timestamp: json["timestamp"], page_id: page.id)
  end

  def insert_revisions_into_page(page_id)
    values = []
    json.each do |r|
      if !(r["minor"]) && !(r["bot"]) && r["user"]
        vandalism = vandalism?(r["tags"])
        author = Author.find_or_create_by(name: r["user"])
        values << [r['revid'], r["timestamp"], vandalism, page_id, author.id]
      end
    end
    columns = [:revid, :timestamp, :vandalism, :page_id, :author_id]
    Revision.import(columns, values)    
  end

  def insert_revisions_into_author(author_id)
    values = []
    json.each do |uc|
      page = Page.find_or_create_by(title: uc["title"])
      values << [uc['revid'], uc["timestamp"], page.id, author_id]
    end
    columns = [:revid, :timestamp, :page_id, :author_id]
    Revision.import(columns, values)        
  end

  def page_exists?
    json["query"]["pages"]["-1"].nil?
  end

  private

  def ip_address?(name)
    !!(/\d{4}:\d{4}:\w{4}:\d{4}:\w{4}:\w{4}:\w{3}:\w{4}|\d{2,3}\.\d{2,3}\.\d{2,3}\.\d{2,3}/.match(name)) 
  end

  def vandalism?(tags)
    tags.include?("possible libel or vandalism")
  end
end

