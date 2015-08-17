class WikiWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: "high"

  def perform(id)
    page = Page.find(id)
    time = Time.now
    Pusher['page_results'].trigger('my_event', {
      message: time
    })    
  end
end

# bundle exec sidekiq
# WikiWorker.perform_async
