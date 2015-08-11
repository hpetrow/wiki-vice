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
    @anonymous_revisions_by_country = @page.anonymous_location_for_view
    gon.revDates = @page.format_rev_dates_for_c3
    gon.revCounts = @page.format_rev_counts_for_c3
    gon.anonLocationMap = @page.anonymous_location_for_map
    
  end
end
