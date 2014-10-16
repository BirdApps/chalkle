# Use this file to easily define all of your cron jobs.

set :output, "/apps/chalkle/#{environment}/shared/log/cron.log"

# every :hour, :at => 15 do
#   rake "chalkle:load_all"
# end


every :day, :at => '12:01am' do 
  rake "chalkle:expire_caches"
  rake "chalkle:create_pending_payments"
end

every :day, :at => '01:00am' do
  rake "mailer:chalkler_digest['daily']"
end

every :day, :at => '02:00am' do
  rake "mailer:booking_reminder"
end
every :day, :at => '02:30am' do
  rake "mailer:booking_completed"
end

every :monday, :at => '01:30am' do
  rake "mailer:chalkler_digest['weekly']"
end

#every :day, :at => '02:00am' do
#  rake "mailer:five_day_reminder"
#end
#
#every :day, :at => '03:00am' do
#  rake "mailer:three_day_reminder"
#end

every :day, :at => '04:30am' do
  path = "/apps/chalkle/db_backups/"
  filename = "chalk_prod_#{DateTime.current.strftime("%d%m%Y%H%M")}.sql"
  command "pg_dump -f #{path + filename} chalkle_production && gzip #{path + filename}"
end
