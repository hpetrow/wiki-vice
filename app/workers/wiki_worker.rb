class WikiWorker
  include Sidekiq::Worker
  def perform(id)
    @page = Page.find(id)
    revision = Revision.new(content: "Hello, World", page_id: id)
    revision.save
    Pusher["page_results_#{id}"].trigger!("alert('done'")
  end
end

# bundle exec sidekiq
# WikiWorker.perform_async
