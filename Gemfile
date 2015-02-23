source 'https://rubygems.org'

gem 'rails', '3.2.21'
gem 'pg', '~> 0.17.1'
gem 'unicorn-rails'
gem 'unicorn-worker-killer'

gem 'entity_events'

gem 'engtagger'

# Authentication
gem 'devise',           '~> 2.2.4'
gem 'devise_invitable'
gem 'omniauth',         '~> 1.1.4'
gem 'omniauth-facebook'

# Authorisation
gem 'pundit'

# Time / Date
gem 'monthify', require: 'monthify'
gem 'chronic',       '~> 0.9.0'

gem 'airbrake',      '~> 4.1.0'
gem 'analytical',    '~> 3.0.12'
gem 'jquery-rails'
gem 'active_attr',   '~> 0.7.0'
gem 'rack-cache', require: 'rack/cache'
gem 'delayed_job_active_record'
gem 'squeel',        '~> 1.0.18'
gem 'validates_timeliness', '~> 3.0'
gem 'whenever', require: false
gem 'premailer-rails', '~> 1.4.0'
gem 'kaminari'
gem 'httparty'
gem 'inherited_resources'
gem 'foreigner'
gem 'color'

#formatting
gem 'lazy_high_charts'
gem 'rdiscount'

#apis
gem 'rMeetup', require: 'rmeetup', github: 'kiesia/rmeetup'
gem 'xeroizer'
gem "geocoder"
gem 'newrelic_rpm'
gem 'mandrill-rails'

#interface
gem 'chosen-rails',  '~> 0.9.11.1'
gem 'haml', '~> 4.0.5'
gem 'haml-rails',    '~> 0.4.0'
#gem 'simple_form'
gem 'simple_form', github: 'zlx/simple_form_bootstrap3', branch: 'rails_3'
gem 'maruku',        '~> 0.6.1'
gem 'draper',        '~> 1.0'
gem 'google-webfonts-rails'
gem 'bootstrap-datepicker-rails'
gem 'twitter-typeahead-rails'
gem 'autoprefixer-rails'

#attachments
gem 'carrierwave'
gem 'carrierwave-imageoptimizer'
gem 'rmagick', require: false
gem 'unf', require: false       # optional dependency used by fog for unicode strings
gem 'fog', ">= 1.3.1", require: false
gem 'mini_magick'

gem 'omni_avatar', path: 'vendor/gems/omni_avatar'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails',        '~> 3.2.2'
  gem 'anjlab-bootstrap-rails', require: 'bootstrap-rails', github: 'anjlab/bootstrap-rails'
  gem 'font-awesome-rails'
  gem 'uglifier',            '~> 1.3.0'
  gem 'haml_coffee_assets',  '~> 1.16'
  gem 'haml_assets',         '~> 0.2.2'
  gem 'kalendae_assets',     '~> 0.2.1'
  gem 'execjs',              '~> 1.4.0'
  gem 'turbo-sprockets-rails3'
end

group :development do
  gem 'rb-readline'

  # Better documentation
  gem 'tomdoc',  '~> 0.2.5',  require: false

  # Testing emails
  gem 'mailcatcher',  '~> 0.5.10',  require: false

  # Deployment
  gem 'capistrano', '~> 3.0',  require: false
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rbenv', '~> 2.0', require: false
  gem 'capistrano3-unicorn', group: :development

  # Helpful Rails Generators
  gem 'nifty-generators',  '~> 0.4.6',  require: false

  # Better error reports and logs
  gem 'meta_request',       '~> 0.2.1'
  gem 'quiet_assets',       '~> 1.0.1'
  gem 'better_errors'
  gem 'binding_of_caller',  '0.7.2'

  # Opening webpages during tests
  gem 'launchy', '~> 2.1.2'

  gem 'guard'
  gem 'guard-rspec', require: false
  # gem 'guard-zeus'
  gem 'guard-cucumber'
  gem 'guard-livereload'


end

group :test, :development do
  # Placed here so generators work
  gem 'rspec-rails'

  gem 'pry-rails'
  gem 'pry-coolline'
  gem 'pry-stack_explorer'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem 'shoulda', '>= 3.5.0'
  gem 'mocha', '>= 0.14.0', require: false

  # Core Testing
  gem 'cucumber-rails',   '~> 1.3.0', require: false
  gem 'capybara'
  # gem 'capybara-webkit'

  # Test Helpers
  gem 'database_cleaner',    '~> 0.9.1'
  gem 'timecop'
  gem 'steak',               '~> 2.0.0'
  gem 'webrat',              '~> 0.7.3'
  gem 'email_spec'
  gem 'factory_girl_rails',  '~> 4.2.1'
  gem 'faker'

  # Test coverage
  gem 'simplecov',  '~> 0.7.1', require: false

end
