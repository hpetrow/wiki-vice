require "rails_helper"

RSpec.feature "User submits a search form" do
  context "the form is valid" do 
    scenario "they see the Page show page" do 
      query = "Donald Trump"
      heading = "Donald Trump"

      visit root_path
      fill_in "query-welcome", with: query
      click_on "Search"

      expect(page).to have_content(heading)
    end
  end

  context "the form is invalid" do 
    scenario "they see an error message" do 
      query = "dfasjf'afa"

      visit root_path
      fill_in "query-welcome", with: query
      click_on "Search"

      expect(page).to have_css("div.alert.alert-danger")
    end
  end


end
