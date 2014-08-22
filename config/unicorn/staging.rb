# workin' directory 
working_directory '/apps/chalkle/staging/current/'

pid '/apps/chalkle/staging/current/pids/unicorn.pid'

stderr_path '/apps/chalkle/staging/current/log/unicorn.log'
stdour_path '/apps/chalkle/staging/current/log/unicorn.log'

#sockets
listen '/tmp/unicorn.chalkle.lock'

#workers
worker_processes 4

timeout 30
