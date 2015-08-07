class AuthorsController < ApplicationController
  def show

    @author = Author.find(params[:id])
    @top_contributions = @author.top_contributions
    gon.data = @top_contributions
    # @comment_info = @author.get_user_contributions_info
  end
end
