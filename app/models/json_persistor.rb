class JsonPersistor
  attr_accessor :json

  def initialize(json)
    @json = json
  end

  def persist_page
    page_id = json["query"]["pages"].keys.first
    page_data = json["query"]["pages"][page_id]
    page = Page.new(title: page_data["title"], page_id: page_id)
    if page.save
      persist_categories(page)
    else
      page = Page.find_by(page_id: page_id)
    end
    page
  end

  def persist_revisions(page)
    revisions = json["query"]["pages"][page.page_id.to_s]["revisions"]
    revisions.each do |r|
      if !(r['tags'].empty?)
        has_vandalism = true 
      else 
        has_vandalism = false
      end
      if r["diff"]
        content = r["diff"]["*"]
      else
        content = "notcached"
      end
      revision = Revision.new(revid: r['revid'], timestamp: r["timestamp"], comment: r["comment"], vandalism: has_vandalism, content: content)
      author = Author.new(name: r["user"])
      author.save
      revision.page = page
      revision.author = author
      revision.save
    end
  end

  def persist_categories(page)
    categories = json["query"]["pages"][page.page_id.to_s]["categories"]
    all_categories = Category.pluck(:title)
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
end