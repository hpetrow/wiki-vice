class PagesController < ApplicationController

  def create
    wiki_wrapper = WikiWrapper.new
    title = wiki_wrapper.get_page(params[:query]).title
    @page = Page.find_or_create_by(title: title)
    redirect_to page_path(@page)
  end

  def show
    @page = Page.find(params[:id])
    @top_five_authors = @page.top_five_authors
    @revisions = @page.revisions
    gon.anonData = @page.group_anonymous_users_by_location
    gon.anonCountryName = @page.find_country_name
  end
end
