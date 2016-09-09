require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'simplecov'
require 'rubygems'
require 'email_spec'
require 'capybara/rspec'
require 'pundit/rspec'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'
prefork = lambda {
  ENV["RAILS_ENV"] = 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  Capybara.javascript_driver = :webkit

  RSpec.configure do |config|
    config.infer_spec_type_from_file_location!
    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
    config.include Devise::TestHelpers, :type => :controller
    config.extend ControllerMacros, :type => :controller
    config.include IntegrationSpecHelper, :type => :request

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"

    config.before(:each, :js => true) do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.strategy = :transaction
    end

    config.before(:each, type: :feature) do
      # :rack_test driver's Rack app under test shares database connection
      # with the specs, so continue to use transaction strategy for speed.
      driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

      if !driver_shares_db_connection_with_specs
        # Driver is probably for an external browser with an app
        # under test that does *not* share a database connection with the
        # specs, so use truncation strategy.
        DatabaseCleaner.strategy = :truncation
      end
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
}

each_run = lambda {}

if defined?(Zeus)
  prefork.call
  $each_run = each_run
  class << Zeus.plan
    def after_fork_with_test
      after_fork_without_test
      $each_run.call
    end
    alias_method_chain :after_fork, :test
  end
else
  prefork.call
  each_run.call
end
