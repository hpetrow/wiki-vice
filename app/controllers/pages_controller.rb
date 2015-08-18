class PagesController < ApplicationController

  def create
    wiki = WikiWrapper.new
    if params["query"] == ""
      redirect_to random_path
    else
      @page = wiki.get_title(params[:query])
      if @page
        redirect_to page_path(@page)
      else
        flash[:notice] = "Can't find #{params[:query]}. Please try again."
        redirect_to root_path
      end      
    end

  end

  def show
    respond_to do |format|
      format.html do 
        @page = Page.find(params[:id])
        WikiWorker.perform_async(@page.id)
      end
      format.js{}
    end
    @page.new_vandalism 
    gon.revDates = @page.format_rev_dates_for_c3
    gon.revCounts = @page.format_rev_counts_for_c3
    gon.anonLocationMap = @page.anonymous_location_for_map
    gon.extractTitle = @page.title
    gon.extractPageId = @page.page_id 
  end

  def dashboard
    @page = Page.find(params[:id])
    @page.new_vandalism 
    gon.revDates = @page.format_rev_dates_for_c3
    gon.revCounts = @page.format_rev_counts_for_c3
    gon.anonLocationMap = @page.anonymous_location_for_map
    gon.extractTitle = @page.title
    gon.extractPageId = @page.page_id      
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
    @page = wiki.random_page
    redirect_to page_path(@page)
  end
end
