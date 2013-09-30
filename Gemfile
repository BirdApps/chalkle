source 'https://rubygems.org'

gem 'rails', '3.2.14'
gem 'pg', '~> 0.15.1'

# Authentication
gem 'devise',           '~> 2.2.4'
gem 'omniauth',         '~> 1.1.4'
gem 'omniauth-meetup',  '~> 0.0.7'

# Authorisation
gem 'cancan',  '~> 1.6.8'

gem 'airbrake',      '~> 3.1.6'
gem 'activeadmin',   '~> 0.5.1'
gem 'analytical',    '~> 3.0.12'
gem 'jquery-rails',  '~> 2.1.4'
gem 'chronic',       '~> 0.9.0'
gem 'active_attr',   '~> 0.7.0'
gem 'dragonfly',     '~> 0.9.14'
gem 'rack-cache', :require => 'rack/cache'
gem 'delayed_job_active_record'
gem 'squeel',        '~> 1.0.18'
gem 'validates_timeliness', '~> 3.0'
gem 'whenever', :require => false
gem 'premailer-rails', '~> 1.4.0'
gem 'google-analytics-rails'
gem 'kaminari'
gem 'httparty'

#apis
gem 'rMeetup',   :git => "git://github.com/kiesia/rmeetup.git",  :require => "rmeetup"
gem 'xeroizer',  :git => "git://github.com/kiesia/xeroizer.git"

#interface
gem 'chosen-rails',  '~> 0.9.11.1'
gem 'haml-rails',    '~> 0.3.5'
gem 'coffee-filter', '~> 0.1.3'
gem 'simple_form',   '~> 2.0.4'
gem 'maruku',        '~> 0.6.1'
gem 'draper',        '~> 1.0'

#attachments
gem 'carrierwave'
gem "rmagick"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',          '~> 3.2.6'
  gem 'coffee-rails',        '~> 3.2.2'
  gem 'anjlab-bootstrap-rails', require: 'bootstrap-rails', github: 'anjlab/bootstrap-rails'
  gem 'font-awesome-rails'
  gem 'uglifier',            '~> 1.3.0'
  gem 'haml_coffee_assets',  '~> 1.9.1'
  gem 'haml_assets',         '~> 0.2.1'
  gem 'kalendae_assets',     '~> 0.2.1'
  gem 'execjs',              '~> 1.4.0'
end

group :development do
  # EXPERIMENTAL
  # gem 'omni_avatar', path: '/Users/craig/development/enspiral/omni_avatar'

  gem 'rb-readline'

  # Better documentation
  gem 'tomdoc',  '~> 0.2.5',  require: false

  # Testing emails
  gem 'mailcatcher',  '~> 0.5.10',  require: false

  # Deployment
  gem 'capistrano',      '~> 2.14.1',  require: false
  gem 'capistrano-ext',  '~> 1.2.1',   require: false

  # Helpful Rails Generators
  gem 'nifty-generators',  '~> 0.4.6',  require: false

  # Better error reports and logs
  gem 'meta_request',       '~> 0.2.1'
  gem 'quiet_assets',       '~> 1.0.1'
  gem 'better_errors',      '~> 0.3.2'
  gem 'binding_of_caller',  '~> 0.6.8'

  # Automatic testing
  gem 'guard',             '~> 1.6.2'
  gem 'guard-spork',       '~> 1.4.1'
  gem 'guard-rspec',       '~> 2.3.3'
  gem 'guard-sass',        '~> 1.0.1', require: false
  gem 'guard-livereload',  '~> 1.1.3'

  # Opening webpages during tests
  gem 'launchy', '~> 2.1.2'

  # Debugging Tools
  gem 'pry-rails',     '~> 0.2.2'
  gem 'pry-coolline',  '~> 0.2.1'
  gem 'debugger'
  gem 'debugger-pry'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem 'shoulda', '>= 3.5.0'
  gem 'spork'
  gem 'mocha', '>= 0.14.0', require: false

  # Placed here so generators work
  gem 'rspec-rails',  '~> 2.12.2'

  # Testing Javascript
  gem 'jasmine',  '~> 1.1.2'
  gem 'jasmine-headless-webkit', '~> 0.8.4'

  # Core Testing
  gem 'cucumber-rails',   '~> 1.3.0', require: false
  gem 'capybara',         '~> 2.0.2'
  gem 'capybara-webkit',  '~> 0.14.0'

  # Test Helpers
  gem 'database_cleaner',    '~> 0.9.1'
  gem 'timecop',             '~> 0.5.9'
  gem 'steak',               '~> 2.0.0'
  gem 'webrat',              '~> 0.7.3'
  gem 'email_spec',          '~> 1.4.0'
  gem 'factory_girl_rails',  '~> 4.2.1'

  # Test coverage
  gem 'simplecov',  '~> 0.7.1', require: false
end
