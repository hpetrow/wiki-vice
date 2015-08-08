require "rails_helper"

RSpec.describe WikiWrapper, "#get_page" do 

  let(:page) { 
    wiki = WikiWrapper.new
    page = wiki.get_page("Donald Trump")
  }

  let(:revisions) {
    wiki = WikiWrapper.new
    page = wiki.get_page("Donald Duck")
    revisions = page.revisions
  }

  it "returns a Page instance" do  
    expect(page.class).to eq Page
  end

  it "returns a page with many revisions" do 
    expect(page.revisions.size).not_to eq 0
  end

  it "returns a page with many authors" do 
    expect(page.authors.size).not_to eq 0
  end

  it "returns revisions with nil content" do 
    expect(revisions.first.content).to eq nil
  end

end
