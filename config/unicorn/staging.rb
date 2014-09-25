# workin' directory 
working_directory '/apps/chalkle/staging/current/'

stderr_path '/apps/chalkle/staging/current/log/unicorn.log'
stdout_path '/apps/chalkle/staging/current/log/unicorn.log'

#sockets
listen 8080

#workers
worker_processes 4

timeout 30


preload_app true