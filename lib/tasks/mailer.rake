begin
  namespace :mailer do

    desc "Send chalkler digest"
    task "send_chalkler_digest", [:frequency] => :environment do |t, args|
      unless (args.frequency == 'daily' || args.frequency == 'weekly')
        puts "task accepts only 'weekly' or 'daily' as valid arguments"
        exit!(1)
      end
      require 'chalkler_digest'
      chalklers = ChalklerDigest.load_chalklers('daily')
      chalklers.each do |c|
        digest = ChalklerDigest.new c
        digest.create!
      end
    end

  end
end
