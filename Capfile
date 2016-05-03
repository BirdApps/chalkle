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
require 'capistrano/sidekiq'
require 'HTTParty'

namespace :slack do 
  desc "slack"
  task :deploy_starts do
    run_locally do 
      message = HTTParty.post "https://hooks.slack.com/services/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", body: {
        username: "Deploy Boy",
        icon_emoji: ":rooster:",
        text: "Deploy to #{fetch(:stage)} has begun!"
        }.to_json,  :headers => { 'Content-Type' => 'application/json' }
    end
  end

  task :deploy_complete do 
    run_locally do
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
    on roles(:app) do 
      within release_path do
        with rails_env: fetch(:rails_env) do
          info fetch(:current)
          rake "chalkle:migrate_images"
        end 
      end
    end
  end
end

# Load custom tasks from `lib/capistrano/tasks' if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }