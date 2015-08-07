class JsonPersistor
  attr_accessor :json

  def initialize(json)
    @json = json
  end

  def persist_page_revisions
    pageid = json["query"]["pages"].keys.first
    page_data = json["query"]["pages"][pageid]
  end

end