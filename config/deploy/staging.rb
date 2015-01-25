# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{chalklestaging.cloudapp.net}
role :web, %w{chalklestaging.cloudapp.net}
role :db,  %w{chalklestaging.cloudapp.net}

set :domain,    "chalklestaging.cloudapp.net"

set :branch,    "staging"
set :rails_env, "staging"

server 'chalklestaging.cloudapp.net', user: 'chalkle', roles: %w{web app db}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.


# ignore this if you do not need SSL
# set :nginx_use_ssl, true
# set :nginx_ssl_cert_local_path, '/path/to/ssl_cert.crt'
# set :nginx_ssl_cert_key_local_path, '/path/to/ssl_cert.key'


# UNICORN setup
set :unicorn_pid, "/apps/chalkle/staging/shared/tmp/pids/unicorn.pid"





# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
