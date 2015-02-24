# workin' directory 
working_directory '/apps/chalkle/staging/current/'

stderr_path '/apps/chalkle/staging/shared/log/unicorn.log'
stdout_path '/apps/chalkle/staging/shared/log/unicorn.log'

#sockets
listen 8080

#workers
worker_processes 2

timeout 64

pid "/apps/chalkle/staging/shared/tmp/pids/unicorn.pid"

preload_app true


before_fork do |server, worker|


  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|


  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection(
      Rails.application.config.database_configuration[Rails.env]
    )

end
