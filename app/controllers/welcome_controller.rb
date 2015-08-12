class WelcomeController < ApplicationController

  def index
    @vandalism = Page.most_recent_revision_vandalism
  end
end
