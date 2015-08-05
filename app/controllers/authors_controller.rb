class AuthorsController < ApplicationController
  def show
    @author = Author.find(params[:id])
    @top_contributions = @author.top_contributions
  end
end
