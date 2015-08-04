class PageController < ApplicationController

  def show
    @page = Page.find(params[:id])
  end
end
