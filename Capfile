# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano3/unicorn'
require "whenever/capistrano"
require 'airbrake/capistrano3'


require 'HTTParty'

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
# require 'capistrano/bundler'
# require 'capistrano/rails/assets'
# require 'capistrano/rails/migrations'
# require 'capistrano/passenger'



namespace :slack do 
  desc "slack"
  task :deploy_starts do
    on roles(:app) do 
      message = HTTParty.post "https://hooks.slack.com/services/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", body: {
        username: "Deploy Boy",
        icon_emoji: ":rooster:",
        text: "Deploy to #{fetch(:stage)} has begun!"
        }.to_json,  :headers => { 'Content-Type' => 'application/json' }
    end
  end

  task :deploy_complete do 
    on roles(:app) do
      message = HTTParty.post "https://hooks.slack.com/services/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", body: {
          username: "Deploy Boy",
          icon_emoji: ":rooster:",
          text: "Successfully deployed to #{fetch(:stage)}"
        }.to_json,  :headers => { 'Content-Type' => 'application/json' }
    end
  end

end

namespace :chalkle do 
  desc "migrate images"
  task :migrate_images do
  on roles(:app) { run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake chalkle:migrate_images" }
  end
  desc "clear_chaches" 
  task :clear_caches do 
    on roles(:app) { run 'cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake chalkle:expire_caches' }
  end
end

# Load custom tasks from `lib/capistrano/tasks' if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
