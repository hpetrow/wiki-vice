class PagesController < ApplicationController

  def create
    wiki_wrapper = WikiWrapper.new
    @page = wiki_wrapper.get_page(params[:query])
    redirect_to page_path(@page)
  end


  def show
    @page = Page.find(params[:id])
  end
end
