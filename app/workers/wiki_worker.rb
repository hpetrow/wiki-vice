require 'pusher'
Pusher.url = "https://0c88ff9f8382fb32596e:6e55dd3d3001f6ed63f7@api.pusherapp.com/apps/136049"
Pusher.logger = Rails.logger

class WikiWorker
  include Sidekiq::Worker
  def perform(id)
    @page = Page.find(id)
    revision = Revision.new(content: "Hello, World", page_id: id)
    revision.save
    puts "\e[31mjob completed\e[0m"
    Pusher.url = "https://0c88ff9f8382fb32596e:6e55dd3d3001f6ed63f7@api.pusherapp.com/apps/136049"
    Pusher["page_results"].trigger!("my_event", {
      message: "Hello, world!"
      })
  end
end

# bundle exec sidekiq
# WikiWorker.perform_async
