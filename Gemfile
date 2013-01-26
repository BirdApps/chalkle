source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'airbrake', '~> 3.1.6'
gem 'devise', '~> 2.2.0'
gem 'cancan', '~> 1.6.8'
gem 'activeadmin', '~> 0.5.1'
gem 'analytical'
gem 'jquery-rails'
gem 'chronic'

#apis
gem 'rMeetup', :git => "git://github.com/kiesia/rmeetup.git", :require => "rmeetup"
gem 'xeroizer', :git => "git://github.com/kiesia/xeroizer.git"

#interface
gem 'chosen-rails'
gem 'haml-rails'
gem 'simple_form'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'bootstrap-sass', '~> 2.0.4.0'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'haml_coffee_assets'
  gem 'haml_assets'
  gem 'kalendae_assets'
  gem 'execjs'
end

group :development do
  # Better documentation
  gem 'tomdoc', :require => false

  # Testing emails
  gem 'mailcatcher', :require => false

  # Deployment
  gem 'capistrano', :require => false
  gem 'capistrano-ext', :require => false

  # Helpful Rails Generators
  gem 'nifty-generators', '>= 0.4.4', :require => false
end

group :development, :test do
  # Automatic testing
  gem 'guard', '~> 1.6.1'
  gem 'guard-spork', '~> 1.4.1'
  gem 'guard-rspec', '~> 2.3.3'
  gem 'guard-sass', '~> 1.0.1', :require => false
  gem 'guard-livereload', '~> 1.1.3'
  gem 'rb-inotify', '~> 0.8.8'

  # Placed here so generators work
  gem 'rspec-rails', '~> 2.0'

  # Opening webpages during tests
  gem 'launchy'

  # Testing Javascript
  gem 'jasmine', '~> 1.1.0.rc2'
  gem 'jasmine-headless-webkit'
end

group :test do
  # Core Testing
  gem 'capybara'
  gem 'capybara-webkit'

  # Test Helpers
  gem 'database_cleaner'
  gem 'timecop'
  gem 'steak'
  gem 'webrat'
  gem 'email_spec'
  gem 'factory_girl_rails', '~> 4.1.0'
  gem 'shoulda'

  # Test coverage
  gem 'simplecov'
end
