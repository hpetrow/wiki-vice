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
    all_categories = Category.pluck(:name)
    categories.each do |category|

    end
  end
end