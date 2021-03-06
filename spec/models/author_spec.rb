require 'rails_helper'

RSpec.describe Author, type: :model do
  
  let (:author) {
    wiki = WikiWrapper.new #test object instead
    page = wiki.get_page("Donald Trump")
    author = page.authors.first
  }

  let (:author_with_name) {
    Author.new(name: "Name")
  }

  context "Author information" do 
    it "Author is initialized with a name" do
      expect(author_with_name.name).to eq "Name" 
    end
  end

  context "#top_contributions" do
    it "increases author's unique pages" do 
      author.top_contributions
      expect(author.pages.uniq).to_not eq 0
    end
  end

  context "#most_recent_revision" do 

    it "returns a revision" do 
      revision = author.most_recent_revision
      expect(revision.class).to eq Revision
    end

    it "returns a revision with content" do 
      revision = author.most_recent_revision
      expect(revision.content).to_not eq nil
    end
  end


end
