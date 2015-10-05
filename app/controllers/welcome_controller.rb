class WelcomeController < ApplicationController

  def index
    wiki = WikiWrapper.new
    results = wiki.recent_changes(5)
    @recent_changes = results.collect do |r| 
      Page.create(page_id: r[:page_id], title: r[:title])
    end
  end
end
