# Use this file to easily define all of your cron jobs.

set :output, '~/production/shared/log/cron.log'

every :hour, :at => 15 do
  rake "chalkle:load_all"
end

every 30.minutes do
  rake "chalkle:load_chalklers"
end

every :hour, :at => 30 do
  rake "chalkle:load_payments"
end

every :day, :at => '01:00am' do
  rake "mailer:chalkler_digest['daily']"
end

every :monday, :at => '01:30am' do
  rake "mailer:chalkler_digest['weekly']"
end

every :day, :at => '04:30am' do
  command "backup perform -t chalkle"
end
