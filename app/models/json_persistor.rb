class JsonPersistor
  attr_accessor :json

  def initialize(json)
    @json = json
  end

  def persist_page_revisions
    page_id = json["query"]["pages"].keys.first
    page_data = json["query"]["pages"][page_id]
    page = Page.new(title: page_data["title"], page_id: page_id)
    if page.save
      persist_categories(page)
    else
      Page.find_by(page_id: page_id)
    end
  end

  def persist_categories(page)
    categories = json["query"]["pages"][page.page_id.to_s]["categories"]
    all_categories = Category.pluck(:title)
    binding.pry
    categories.each do |category|
      category_title = /^Category:(.+)/.match(category['title'])[1]
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