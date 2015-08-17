class PagesController < ApplicationController

  def create
    wiki = WikiWrapper.new
    if params["query"] == ""
      redirect_to random_path
    else
      @page = wiki.get_title(params[:query])
      if @page
        WikiWorker.perform_async(@page.id) 
        redirect_to page_path(@page)
      else
        flash[:notice] = "Can't find #{params[:query]}. Please try again."
        redirect_to root_path
      end      
    end

    #@job = WikiWorker.perform_async
  end

  def show
    respond_to do |format|
      format.html do 
        @page = Page.find(params[:id])
        WikiWorker.perform_async(@page.id)
      end
      format.json do 
        WikiWorker.perform_async(@page.id)
        render json: :success
      end
      format.js{}
    end
    # Pusher["page_results"].trigger("get_page", {
    #           title: "WTF",
    #           revisionRate: "WTF"
    #           })          
    # Pusher['page_results'].trigger('my_event', {
    #   message: 'hello world'
    # })        
    # if @page.revisions.size < 10
    #   wiki = WikiWrapper.new
    #   @page = wiki.get_page(@page.title)
    # end
    # @page.new_vandalism
    # gon.revDates = @page.format_rev_dates_for_c3
    # gon.revCounts = @page.format_rev_counts_for_c3
    # gon.anonLocationMap = @page.anonymous_location_for_map
    # gon.extractTitle = @page.title
    # gon.extractPageId = @page.page_id
  end

  def dashboard
    @page = Page.find(params[:id])
  end

  def random
    wiki = WikiWrapper.new
    @page = wiki.random_page
    redirect_to page_path(@page)
  end
end
