module Notify
  def self.for(object)
    begin
      notifier = ('Notify::'+object.class.to_s+'Notification').constantize.new(object)
    rescue
      puts 'Cannot notify for that'
    end
  end
end