class JsonPersistor
  attr_accessor :json

  def initialize(json)
    @json = json
  end

  def persist_page_revisions
    page_id = json["query"]["pages"].keys.first
    page_data = json["query"]["pages"][page_id]
    binding.pry
    page = Page.new(title: page_data["title"], page_id: page_id)
    if page.save
    else
      Page.find_by(page_id: page_id)
    end
  end

end