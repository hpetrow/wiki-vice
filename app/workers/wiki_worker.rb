class WikiWorker
  require "pusher"
  include Sidekiq::Worker

  def perform(id)
    page = Page.find(id)
    wiki = WikiWrapper.new
    page = wiki.get_page(page.title)
    puts "Hello world"
    pusher = Pusher::Client.new(
    { 
      app_id: '136049',
      key: '0c88ff9f8382fb32596e',
      secret: '6e55dd3d3001f6ed63f7'
    }
    ) 
    sleep(10)
    pusher.trigger("page_results_#{page.id}", "get_page", {:id => page.id, :title => page.title, :revisionRate => page.time_between_revisions})
  end
end

# bundle exec sidekiq
# WikiWorker.perform_async
