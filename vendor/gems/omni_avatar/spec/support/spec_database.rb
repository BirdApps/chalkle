require 'active_record'

db_params = {
  database: 'omni_avatar_test',
  adapter: 'sqlite3'
}
ActiveRecord::Base.establish_connection db_params
