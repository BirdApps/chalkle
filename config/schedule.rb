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

every :day, :at => '05:30pm' do
  rake "mailer:course_digest"
end

every :hour do
  command "backup perform -t chalkle_hourly"
end

# every :day, :at => '04:30pm' do
#   command "backup perform -t chalkle_daily"
# end
