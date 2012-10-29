default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :application, "chalkle"
set :repository,  "git@github.com:enspiral/#{application}.git"
set :user,        application 
set :rake, "bundle exec rake"

set :use_sudo,    false
set :scm, :git

task :staging do
  set :domain,    "newchalkle.enspiral.info"
  set :branch,    "staging"
  set :rails_env, "staging"
  set :deploy_to, "/home/#{user}/staging"

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

after 'deploy:update_code' do
  deploy.symlink_configs
end

require "./config/boot"
load 'deploy/assets'
require "bundler/capistrano"
