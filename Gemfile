source 'https://rubygems.org'

ruby '2.2.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'nokogiri'
gem "font-awesome-rails"
gem 'gon'
# Adds functionality to search for location based on IP address.
gem 'geoip'
#adds turbolinks
gem 'turbolinks'
# Whenever is a Ruby gem that provides a clear syntax for writing and deploying cron jobs.
gem 'whenever', :require => false
# It provides a convenient way to generate a diff from two strings or files. 
gem 'diffy', '~> 3.0.7'
# Wikitext is a fast wikitext-to-HTML translator written in C.
gem 'wikitext', '~> 4.1.2'

gem "typhoeus"

gem "activerecord-import", ">= 0.2.0"
# colorizes terminal output
gem "colorize"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'google-search', '~> 1.0.3'
gem 'figaro'
gem 'twitter'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'factory_girl_rails'
  gem 'simplecov'
  gem 'database_cleaner'
  gem 'sqlite3'
  gem 'pry'
  gem 'pry-rails'
  gem 'guard-rspec', require: false
  gem 'thin'
end

group :production do
  gem 'pg'
  gem 'google-analytics-rails'
  gem 'rails_12factor'
end

gem 'bootstrap-sass', '~> 3.1.1'