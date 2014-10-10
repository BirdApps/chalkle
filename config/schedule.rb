# Use this file to easily define all of your cron jobs.

set :output, "/apps/chalkle/#{environment}/shared/log/cron.log"

# every :hour, :at => 15 do
#   rake "chalkle:load_all"
# end

every :hour, :at => 30 do
  rake "chalkle:load_payments"
end

every :day, :at => '12:01am' do 
  rake "chalkle:expire_caches"
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
  command "backup perform -t chalkle"
end
