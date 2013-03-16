begin
  namespace :mailer do

    desc "Send chalkler daily digest"
    task "load_all" => :environment do
      require 'chalkler_digest'
      chalklers = ChalklerDigest.load_chalklers('daily')
      chalklers.each do |c|
        digest = ChalklerDigest.new c
        digest.create!
      end
    end

  end
end
