class PagesController < ApplicationController

  def create
    if params["query"] == ""
      redirect_to random_path
    else
      wiki = WikiWrapper.new
      results = wiki.get_title(params[:query])
      if results
        @page = Page.find_or_create_by(page_id: results[:page_id], title: results[:title])    
        redirect_to page_path(@page)
      else
        flash[:notice] = "Can't find #{params[:query]}. Please try again."
        redirect_to root_path
      end      
    end
  end

  def show
    @page = Page.find(params[:id])
    if @page.revisions.empty?
      WikiWorker.perform_async(@page.id)
    end
    gon.extractTitle = @page.title
    gon.extractPageId = @page.page_id 
  end

  def dashboard
    @page = Page.find(params[:id])
    @page.new_vandalism 
  end

  def map
    @page = Page.find(params[:id])
    respond_to do |format|
      format.json {
        render json: {:mapData => @page.anonymous_location_for_map}
      }
    end
  end

  def histogram
    @page = Page.find(params[:id])
    respond_to do |format|
      format.json {
        render json: {
          revDates: @page.format_rev_dates_for_c3,
          revCounts: @page.format_rev_counts_for_c3
        }
      }
    end
  end

  def random
    wiki = WikiWrapper.new
    results = wiki.random_page
    @page = Page.find_or_create_by(page_id: results[:page_id], title: results[:title])
    redirect_to page_path(@page)
  end
end
