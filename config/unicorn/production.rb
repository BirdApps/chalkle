# workin' directory
working_directory '/apps/chalkle/production/current/'

stderr_path '/apps/chalkle/production/shared/log/unicorn.log'
stdout_path '/apps/chalkle/production/shared/log/unicorn.log'

#sockets
listen 8080

#workers
worker_processes 3

timeout 64

pid "/apps/chalkle/production/shared/tmp/pids/unicorn.pid"


preload_app true


before_fork do |server, worker|

    old_pid = "#{server.config[:pid]}.oldbin"
    if old_pid != server.pid
      begin
        sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
        Process.kill(sig, File.read(old_pid).to_i)
      rescue Errno::ENOENT, Errno::ESRCH
      end
    end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection(
      Rails.application.config.database_configuration[Rails.env]
    )

end
