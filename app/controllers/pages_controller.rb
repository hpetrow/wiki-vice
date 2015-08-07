class PagesController < ApplicationController

  def create
    wiki_wrapper = WikiWrapper.new
    @page = wiki_wrapper.get_page(params[:query])      
    redirect_to page_path(@page)
  end

  def show
    @page = Page.find(params[:id])
    @top_five_authors = @page.top_five_authors
    @revisions = @page.revisions
    gon.anonData = @page.group_anonymous_users_by_location
    gon.anonCountryName = @page.find_country_name
    @first_revision = @revisions.first 
    @last_ten_revisions = @revisions.slice(1,9) 
    gon.params = params
  end
end
