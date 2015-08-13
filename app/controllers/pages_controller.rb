class PagesController < ApplicationController

  def create
    wiki = WikiWrapper.new
    @page = wiki.get_page(params[:query])
    if @page
      redirect_to page_path(@page)
    else
      flash[:notice] = "Can't find #{params[:query]}. Please try again."
      redirect_to root_path
    end
  end

  def show
    @page = Page.find(params[:id])
    @page.new_vandalism
    gon.revDates = @page.format_rev_dates_for_c3
    gon.revCounts = @page.format_rev_counts_for_c3
    gon.anonLocationMap = @page.anonymous_location_for_map
    gon.extractTitle = @page.title
    gon.extractPageId = @page.page_id
  end
end
