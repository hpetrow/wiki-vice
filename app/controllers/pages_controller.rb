class PagesController < ApplicationController

  def create
    wiki_wrapper = WikiWrapper.new
    @page = wiki_wrapper.get_page(params[:query])
    if @page    
      redirect_to page_path(@page)
    else
      flash[:notice] = "Can't find #{params[:query]}. Please try again."
      redirect_to root_path
    end
  end

  def show
    @page = Page.find(params[:id])
    @top_five_authors = @page.top_five_authors
    @revisions = @page.revisions
    @first_revision = @revisions.first 
    @last_ten_revisions = @revisions.slice(1,9) 
    gon.anonData = @page.group_anonymous_users_by_location
    gon.anonCountryName = @page.find_country_name
    
  end
end
