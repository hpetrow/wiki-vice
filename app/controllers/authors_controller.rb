class AuthorsController < ApplicationController
  def show

    @author = Author.find(13)
    @top_contributions = @author.top_contributions
    gon.data = @top_contributions
  end
end
