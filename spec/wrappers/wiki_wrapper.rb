require "rails_helper"

RSpec.describe WikiWrapper, "#get_page" do 

  let(:page) { 
    wiki = WikiWrapper.new
    page = wiki.get_page("Donald Trump")
  }

  it "returns a Page instance" do  
    expect(page.class).to eq Page
  end

  context "page" do 
    it "page has a title" do
      expect(page.title).to_not eq nil
    end

    it "page has a page_id" do 
      expect(page.page_id).to_not eq nil
    end    
  end

  context "page revisions" do 
    it "page has many revisions" do 
      expect(page.revisions.size).not_to eq 0
    end

    it "revisions have nil content" do 
      expect(page.revisions.first.content).to eq nil
    end

    it "page does not have duplicate revisions" do 
      revisions_count = page.revisions.size
      unique_revisions_count = page.revisions.uniq.size
      expect(revisions_count).to eq unique_revisions_count
    end    

  end

  context "page authors" do 
    it "page has many authors" do 
      expect(page.authors.size).not_to eq 0
    end

    it "page has no authors with nil name" do 
      has_nil_names = page.authors.any?{|a| a.name.nil? }
      expect(has_nil_names).to eq false
    end


    it "page's authors have one unique page" do
      expect(page.authors.first.pages.uniq.size).to eq 1
    end

    it "page has duplicate authors" do 
      authors_count = page.authors.size
      unique_authors_count = page.authors.uniq.size
      expect(authors_count).to_not eq unique_authors_count
    end

  end
end

RSpec.describe WikiWrapper, "#get_user_contributions" do 

  let(:author) {
    wiki = WikiWrapper.new
    page = wiki.get_page("Taylor Swift")
    author = page.authors.first
    wiki.get_user_contributions(author)
    author
  }

  it "increases unique pages of author" do 
    expect(author.pages.uniq.size).to_not eq 1
  end
end