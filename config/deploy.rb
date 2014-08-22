require "capistrano-rbenv"
require "bundler/capistrano"
require 'capistrano-unicorn'

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

task :staging do
  set :domain,    "chalklestaging.cloudapp.net"
  set :branch,    "feature/heroku"
  set :rails_env, "staging"
  set :deploy_to, "/apps/chalkle/staging"
  set :bundle_without, [:development, :test]

  role :web, domain
  role :app, domain
  role :db,  domain, :primary => true
end

task :production do
  set :domain,    "my.chalkle.com"
  set :branch,    "master"
  set :rails_env, "production"
  set :deploy_to, "/home/#{user}/production"
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


after 'deploy:restart', 'unicorn:reload'    # app IS NOT preloaded
after 'deploy:restart', 'unicorn:restart'   # app preloaded
after 'deploy:restart', 'unicorn:duplicate' # before_fork hook implemented (zero downtime deployments)


after "deploy:update_code", "dragonfly:symlink", "deploy:symlink_configs", "deploy:migrate"
after "deploy:update", "deploy:cleanup"

require './config/boot'
load 'deploy/assets'
require 'bundler/capistrano'
require 'airbrake/capistrano'
# require 'whenever/capistrano'
