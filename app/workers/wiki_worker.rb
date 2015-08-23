class WikiWorker
  require "pusher"
  include Sidekiq::Worker

  def perform(id)
    page = Page.find(id)
    wiki = WikiWrapper.new
    page = wiki.get_page(page.title)

    pusher = Pusher::Client.new(
    { 
      app_id: ENV["PUSHER_APP_ID"],
      key: ENV["PUSHER_KEY"],
      secret: ENV["PUSHER_SECRET"]
    }
    ) 
    pusher.trigger("page_results_#{page.id}", "get_page", {:id => page.id, :title => page.title, :revisionRate => page.time_between_revisions})
  end
end