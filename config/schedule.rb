# Use this file to easily define all of your cron jobs.

####################
# REMEMBER         #
# TIMES ARE IN UTC #
####################

set :output, "/apps/chalkle/#{environment}/shared/log/cron.log"

every :hour do 
  rake "chalkle:complete_courses"
end

every 6.minutes do
  rake "chalkle:verify_payments"
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

every :hour do
  path = "/apps/chalkle/db_backups/hourly/"
  filename = "chalk_prod_#{DateTime.now.strftime("%Y%m%d%H%M")}.sql"
  command "cd #{path} && ls | grep chalk_prod_ | xargs rm"
  command "pg_dump -f #{path + filename} chalkle_production && gzip #{path + filename}"
end

every :day, :at => '04:30pm' do
  path = "/apps/chalkle/db_backups/"
  filename = "chalk_prod_#{DateTime.now.strftime("%Y%m%d%H%M")}.sql"
  command "pg_dump -f #{path + filename} chalkle_production && gzip #{path + filename}"
end