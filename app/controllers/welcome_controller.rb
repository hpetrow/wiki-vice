class WelcomeController < ApplicationController

  def index
    wiki = WikiWrapper.new
    @recent_changes = wiki.recent_changes(5)
  end
end
