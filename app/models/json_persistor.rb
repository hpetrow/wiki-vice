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
    persist_page_categories(page)
    persist_page_revisions(page)
    page
  end

  def persist_page_revisions(page)
    revisions = json["query"]["pages"][page.page_id.to_s]["revisions"]
    revisions.each do |r|

      if r["diff"]
        content = r["diff"]["*"]
      else
        content = "notcached"
      end

      author_name = !!r["user"] ? r["user"] : "anonymous"
      author = Author.find_or_create_by(name: r["user"])
       
      revision = Revision.new(revid: r['revid'], timestamp: r["timestamp"], comment: r["comment"], vandalism: vandalism?(r["tags"]), content: content)
      if revision.valid?
        revision.page = page
        revision.author = author
        revision.save
      end
    end
  end

  def page_exists?
    binding.pry
    json["query"]["pages"]["-1"].nil?
  end

  private

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


  def vandalism?(tags)
    tags.include?("possible libel or vandalism")
  end
end