require "capistrano-rbenv"
require "bundler/capistrano"
require 'hipchat/capistrano'
# require 'capistrano-unicorn'

set :bundle_flags, "--deployment --quiet --binstubs"


set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

set :rbenv_ruby_version, "1.9.3-p545"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :rbenv_setup_default_environment, false


set :application, "chalkle"
set :repository,  "git@github.com:enspiral/#{application}.git"
set :user,        application
set :rake, "bundle exec rake"

set :use_sudo,    false
set :scm, :git

set :whenever_command, "bundle exec whenever"
set :whenever_environment, defer { rails_env }
set :whenever_identifier, defer { "#{application}_#{rails_env}" }

set :hipchat_token, "LtCXRyFQRGwiDiiAO9G7H74dBRCpMoXhrO0xM82p"
set :hipchat_room_name, "Chalkle"
set :hipchat_announce, true # notify users?
set :hipchat_options, {
  :api_version  => "v2" # Set "v2" to send messages with API v2
}
set :hipchat_color, 'yellow' #normal message color
set :hipchat_success_color, 'green' #finished deployment message color
set :hipchat_failed_color, 'red' #cancelled deployment message color
set :hipchat_message_format, 'html' # Sets the deployment message format, see https://www.hipchat.com/docs/api/method/rooms/message
set :hipchat_commit_log, true
# Optional
set :hipchat_commit_log_message_format, "^CHAL-\d+" # extracts ticket number from message


task :staging do
  set :domain,    "chalklestaging.cloudapp.net"
  set :branch,    "staging"
  set :rails_env, "staging"
  set :deploy_to, "/apps/chalkle/staging"
  set :bundle_without, [:development, :test]

  role :web, domain
  role :app, domain
  role :db,  domain, :primary => true
end

task :production do
  set :domain,    "chalkleprod.cloudapp.net"
  set :branch,    "master"
  set :rails_env, "production"
  set :deploy_to, "/apps/chalkle/production"
  set :bundle_without, [:development, :test]

  role :web, domain
  role :app, domain
  role :db,  domain, :primary => true
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_configs do
    run %( cd #{release_path} &&
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml
    )
  end
end

namespace :assets do
  task :precompile, :roles => :web do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
  end

  task :cleanup, :roles => :web do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake assets:clean"
  end
end

namespace :dragonfly do
  desc "Symlink the Rack::Cache files"
  task :symlink, :roles => [:app] do
    run "mkdir -p #{shared_path}/tmp/dragonfly && ln -nfs #{shared_path}/tmp/dragonfly #{release_path}/tmp/dragonfly"
  end
end

namespace :chalkle do 
  desc "migrate images"
  task :migrate_images, :roles => [:app] do 
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake chalkle:migrate_images"
  end
  desc "clear_chaches" 
  task :clear_caches, :roles => [:app] do 
    run 'cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake chalkle:expire_caches'
  end
end


after "deploy:update_code", "dragonfly:symlink", "deploy:symlink_configs", "deploy:migrate"
after "deploy:update", "deploy:cleanup"
after "deploy", "unicorn:restart"

namespace :unicorn do 
  desc "unicorn things"
  task :restart, :roles => :app do 
    run "#{sudo} service unicorn restart"
  end
end


require './config/boot'
load 'deploy/assets'
require 'bundler/capistrano'
require 'airbrake/capistrano'
require 'whenever/capistrano'
