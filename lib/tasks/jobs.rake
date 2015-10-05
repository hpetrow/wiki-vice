namespace :jobs do
  desc "Heroku jobs"
  task work: :environment do
    system("redis-server")
    system("bundle exec sidekiq")
  end

end
