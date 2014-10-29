# Use this file to easily define all of your cron jobs.

####################
# REMEMBER         #
# TIMES ARE IN UTC #
####################

set :output, "/apps/chalkle/#{environment}/shared/log/cron.log"



every :hour do 
  rake "chalkle:expire_caches"
  rake "chalkle:complete_courses"
end

#run on the half hour to no conflict with complete_courses
every :day, :at => '12:30pm' do
  rake "chalkle:calculate_outgoings"
end

every :day, :at => '02:00pm' do
  rake "mailer:booking_reminder"
end

every :day, :at => '02:30pm' do
  rake "mailer:booking_completed"
end

every :day, :at => '01:00pm' do
  rake "mailer:chalkler_digest['daily']"
end

every :monday, :at => '01:30pm' do
  rake "mailer:chalkler_digest['weekly']"
end

every :hour do
  path = "/apps/chalkle/db_backups/hourly/"
  filename = "chalk_prod_#{DateTime.current.strftime("%d%m%Y%H%M")}.sql"
  command "cd #{path} && rm chalkle_prod_*"
  command "pg_dump -f #{path + filename} chalkle_production && gzip #{path + filename}"


every :day, :at => '04:30pm' do
  path = "/apps/chalkle/db_backups/"
  filename = "chalk_prod_#{DateTime.current.strftime("%d%m%Y%H%M")}.sql"
  command "pg_dump -f #{path + filename} chalkle_production && gzip #{path + filename}"
end