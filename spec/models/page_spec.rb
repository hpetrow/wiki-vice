require 'rails_helper'

RSpec.describe Page, type: :model do
  
  it "is invalid with a duplicate title" do
    page1 = Page.new(title: "Mickey Mouse")
    page1.save
    page2 = Page.new(title: "Mickey Mouse")
    expect(page2).to_not be_valid
  end
  it "is invalid with a duplicate page_id" do 
    page1 = Page.new(page_id: 20859)
    page1.save
    page2 = Page.new(page_id: 20859)
    expect(page2).to_not be_valid
  end
  it "returns the top five most popular authors on the page"
  it "returns the date of the most recent revision"
  it "returns the count of anonymous authors"
  it "returns the average days between revisions"
  it "returns the latest revision"
end
