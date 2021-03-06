# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'chalkle'
set :repo_url, "git@github.com:enspiral/#{fetch(:application)}.git"

set :user, fetch(:application)

set :bundle_flags, "--deployment --quiet --binstubs"

set :rbenv_ruby_version, "2.1.5"
set :rbenv_setup_default_environment, false

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :deploy_to, "/apps/#{fetch(:application)}/#{fetch(:stage)}"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true


set :rbenv_type, :system # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.1.5'
set :rbenv_custom_path, '/home/chalkle/.rbenv'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value




# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5


namespace :deploy do

  after :starting, 'slack:deploy_starts'
  after :publishing, 'slack:deploy_complete'
  after :publishing, 'airbrake:deploy'

  # before :publishing, 'unicorn:stop'
  # after :publishing, :restart

  after :publishing, 'unicorn:restart'

end