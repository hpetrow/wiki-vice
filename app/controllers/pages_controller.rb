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
    @top_five_authors = @page.top_five_authors
    @top_revisions = @page.top_revisions
    @revision_parser = RevisionParser.new(@top_revisions.first)
    @anonymous_revisions_by_country = @page.anonymous_location_for_view
    gon.revDates = @page.format_rev_dates_for_c3
    gon.revCounts = @page.format_rev_counts_for_c3
    gon.anonLocationMap = @page.anonymous_location_for_map
    wiki_wrapper = WikiWrapper.new
    @photo_name = wiki_wrapper.get_page_photo(@page.title)
    @photo_url = wiki_wrapper.get_full_res_photo_url(@photo_name)  
  end
end
