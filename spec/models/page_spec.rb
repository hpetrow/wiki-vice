require 'rails_helper'

RSpec.describe Page, type: :model do
  let(:page) {
    wiki = WikiWrapper.new
    page = wiki.get_page("Donald Trump")
  }  
  
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

  context "#top_five_authors" do 
    it "returns a hash" do 
      expect(page.top_five_authors.all?{|tp| tp.class == Hash}).to eq true
    end

    it "hash contains an author object" do 
      expect(page.top_five_authors.all?{|tp| tp[:author].class == Author}).to eq true
    end

    it "hash contains a count" do 
      expect(page.top_five_authors.all?{|tp| tp[:count].class == Fixnum}).to eq true
    end
  end

  context "#get_date" do 
    let(:months) { 
        [
          "January", "February", "March", "April", "May", 
          "June", "July", "August", "September", "October", 
          "November", "December"
        ]
      }  
    it "has a month" do 
      expect(months.any?{ |m| page.get_date.include?(m) }).to eq true
    end

    it "has a day of the month" do 
      date = page.get_date
      match = /[0-2][0-9]|[3][0-1]/.match(date)
      expect(!!match).to eq true
    end

    it "has a year" do 
      date = page.get_date
      match = /[1-2][0-9][0-9][0-9]/.match(date)
      expect(!!match).to eq true
    end

    it "has a time" do 
      date = page.get_date
      match = /([0-1][0-9]|[2][0-4]):[0-6][0-9]/.match(date)
      expect(!!match).to eq true
    end
  end

  context "#get_anonymous_authors" do 
    it "returns an array" do 
      expect(page.get_anonymous_authors.class).to eq Array
    end

    it "returns an array of Author objects" do 
      expect(page.get_anonymous_authors.all?{|a| a.class == Author}).to eq true
    end

    it "returns an array of author with IP address names" do 
      match = page.get_anonymous_authors.all?{|a| /\d{4}:\d{4}:\w{4}:\d{4}:\w{4}:\w{4}:\w{3}:\w{4}|\d{2,3}\.\d{2,3}\.\d{2,3}\.\d{2,3}/.match(a.name)}
      expect(match).to eq true
    end
  end
  
  context "#get_number_of_anonymous_authors" do 
    it "returns the count of anonymous authors" do 
      expect(page.get_number_of_anonymous_authors.class).to eq Fixnum
    end
  end

  context "#days_between_revisions" do 
    it "returns the average days between revisions" do 
      expect(page.days_between_revisions.class).to eq Float
    end
  end

  context "#latest_revision" do 
    it "returns the latest revision" do
      expect(page.latest_revision.content).to_not eq nil
    end
  end
  
end
