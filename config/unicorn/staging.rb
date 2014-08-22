# workin' directory 
working_directory '/apps/chalkle/staging/current/'

stderr_path '/apps/chalkle/staging/current/log/unicorn.log'
stdout_path '/apps/chalkle/staging/current/log/unicorn.log'

#sockets
listen '/tmp/unicorn.chalkle.sock'

#workers
worker_processes 4

timeout 30
