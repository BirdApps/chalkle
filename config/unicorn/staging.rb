# workin' directory 
working_directory '/apps/chalkle/staging/current/'

stderr_path '/apps/chalkle/staging/shared/log/unicorn.log'
stdout_path '/apps/chalkle/staging/shared/log/unicorn.log'

#sockets
listen 8080

#workers
worker_processes 2

timeout 64

pid "/apps/chalkle/production/shared/tmp/pids/unicorn.pid"

preload_app true


before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection(
      Rails.application.config.database_configuration[Rails.env]
    )

end
