source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'airbrake'
gem 'devise'

gem 'activeadmin'

gem 'analytical'

gem 'jquery-rails'

#apis
gem 'rmeetup2'
gem 'xeroizer'

#interface
gem 'chosen-rails'
gem 'html5-rails'
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

  gem 'guard-livereload'
end

group :development, :test do
  # Debugging depending on the ruby you are running
  gem 'hpricot'

  # Automatic testing
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-sass'
  gem 'guard-spork'

  # Placed here so generators work
  gem 'rspec'
  gem 'rspec-rails'

  # Opening webpages during tests
  gem 'launchy'

  # Testing Javascript
  gem 'jasmine', '~> 1.1.0.rc2'
  gem 'jasmine-headless-webkit'

  gem 'spork-rails'
end

group :test do
  # Core Testing
  gem 'capybara'
  gem 'capybara-webkit'

  # Test Helpers
  gem 'database_cleaner'
  gem 'faker'
  gem 'timecop'
  gem 'steak'
  gem 'webrat'
  gem 'email_spec'
  gem 'factory_girl_rails'

  # Test coverage
  gem 'simplecov'

  # Test feedback
  gem 'autotest'
  gem 'rspec-instafail', :require => false
  gem 'fuubar'
end
