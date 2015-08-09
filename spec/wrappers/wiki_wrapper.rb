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

    it "page has many revisions" do 
      expect(page.revisions.size).not_to eq 0
    end

    it "page does not have duplicate revisions" do 
      revisions_count = page.revisions.size
      unique_revisions_count = page.revisions.uniq.size
      expect(revisions_count).to eq unique_revisions_count
    end    

    it "page has many authors" do 
      expect(page.authors.size).not_to eq 0
    end    

    it "page has duplicate authors" do 
      authors_count = page.authors.size
      unique_authors_count = page.authors.uniq.size
      expect(authors_count).to_not eq unique_authors_count
    end    

  end

  context "page revisions" do 

    it "revisions have revid" do 
      expect(page.revisions.all?{|r| r.revid}).to eq true
    end

    it "revisions have a timestamp" do 
      expect(page.revisions.all?{|r| r.timestamp}).to eq true
    end

    it "revisions have nil content" do 
      expect(page.revisions.all?{|r| r.content}).to eq false
    end

    it "revisions have a page" do 
      expect(page.revisions.all?{|r| r.page}).to eq true
    end

  end

  context "page authors" do 

    it "authors have a name" do 
      expect(page.authors.all?{|a| a.name}).to eq true
    end

    it "author has pages" do 
      expect(page.authors.all?{|a| a.pages}).to eq true
    end    

    it "page's authors have one unique page" do
      expect(page.authors.all?{|a| a.pages.uniq.size == 1}).to eq true
    end

  end

  context "page categories" do 
    it "has many categories" do 
      expect(page.revisions.size).to_not eq 0
    end

    it "does not have duplicate categories" do 
      categories = page.categories
      unique_categories = page.categories.uniq
      expect(categories.size).to eq unique_categories.size
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

RSpec.describe WikiWrapper, "#get_revision_content" do 
  let(:page) {
    wiki = WikiWrapper.new
    page = wiki.get_page("San Pellegrino")
  }

  it "fills a revision with content" do 
    wiki = WikiWrapper.new
    wiki.get_revision_content(page.revisions.first)

    expect(page.revisions.first.content).to_not eq nil
  end
end