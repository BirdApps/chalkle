#require 'rubygems'
require 'bundler'
require 'rspec'
Bundler.setup :default, :development, :test

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)

require 'rspec/rails'
require 'rspec/autorun'

ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), ".."))
ActiveRecord::Migrator.migrate(File.join(ROOT_PATH, 'db', 'migrate/'))

Rails.backtrace_cleaner.remove_silencers!

# Load support files
#Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end