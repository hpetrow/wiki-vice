require "rails_helper"

RSpec.describe WikiWrapper, "#get_page" do 
  wiki = WikiWrapper.new
  page = wiki.get_page("Donald Trump")

  it "returns a Page instance" do 
    expect(page.class).to eq Page
  end

end