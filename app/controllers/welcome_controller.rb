class WelcomeController < ApplicationController

  def index
    @vandalism = Page.first
  end
end
