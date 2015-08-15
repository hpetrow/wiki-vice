class WikiWorker
  include Sidekiq::Worker

  def perform
    puts 'Doing hard work'
  end
end

# bundle exec sidekiq
# WikiWorker.perform_async
