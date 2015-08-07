class AuthorsController < ApplicationController
  def show

    @author = Author.find(13)
    @top_contributions = @author.top_contributions
    gon.data = @top_contributions
    # @author = Author.find(params[:id])
    # @top_contributions = @author.top_contributions
    # gon.data = @top_contributions.collect{|tp| [tp[0], tp[1]]}
  end
end
