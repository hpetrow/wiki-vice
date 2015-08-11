class JsonPersistor
  attr_accessor :json

  def initialize(json)
    @json = json
  end

  def persist_page
    page_id = json["query"]["pages"].keys.first
    page_data = json["query"]["pages"][page_id]
    Page.where(page_id: page_id).destroy_all
    page = Page.new(title: page_data["title"], page_id: page_id)
    persist_page_revisions(page)
    page
  end

  def persist_page_revisions(page)
    revisions = json["query"]["pages"][page.page_id.to_s]["revisions"] || []
    revisions.each do |r|
      author_name = !!r["user"] ? r["user"] : "anonymous"
      ip_address?(author_name) ? anonymous = true : anonymous = false
      author = Author.find_or_create_by(name: author_name, anonymous: anonymous)
      if !(r["minor"]) && !(r["bot"])
        revision = Revision.new(revid: r['revid'], timestamp: r["timestamp"], vandalism: vandalism?(r["tags"]), size: r["size"])
        if revision.valid?
          revision.page = page
          revision.author = author
          revision.save
        end
      end
    end
  end

  def page_exists?
    json["query"]["pages"]["-1"].nil?
  end

  def persist_author_revisions(author)
    usercontribs = json["query"]["usercontribs"]
    usercontribs.each do |uc|
      page = Page.new(page_id: uc["pageid"], title: uc["title"])
      if !(page.valid?)
        page = Page.find_by(page_id: uc["pageid"])
      end  
      revision = Revision.new(revid: uc["revid"], timestamp: uc["timestamp"])
      if revision.valid?
        revision.page = page
        revision.author = author
        revision.save      
      else
        Revision.find_by(revid: uc["revid"])
      end
    end
  end

  def persist_revision_content(revision)
    revisions = json["query"]["pages"][revision.page.page_id.to_s]["revisions"]
    revisions.each do |r|
      if r["diff"]
        revision.content = r["diff"]["*"]
      else
        revision.content = "notcached"
      end
      revision.save
    end
  end

  private

  def parse_author(data)

  end

  def parse_revision_content(data)
    if data["diff"]
      content = data["diff"]["*"]
    else
      content = "notcached"
    end
  end

  def persist_page_categories(page)
    categories = json["query"]["pages"][page.page_id.to_s]["categories"]
    categories.each do |c|
      category_title = /^Category:(.+)/.match(c['title'])[1]
      category = Category.new(title: category_title)
      if category.valid?
        category.page = page
        category.save
      else
        category = Category.find_by(title: category_title)
        category.page = page
        category.save
      end
    end
  end

  def ip_address?(name)
    /\d{4}:\d{4}:\w{4}:\d{4}:\w{4}:\w{4}:\w{3}:\w{4}|\d{2,3}\.\d{2,3}\.\d{2,3}\.\d{2,3}/.match(name)    
  end

  def vandalism?(tags)
    tags.include?("possible libel or vandalism")
  end
end