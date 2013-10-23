class EventLog < ActiveRecord::Base
  attr_protected []

  def self.log(name)
    record = self.create!(name: name, started_at: Time.now)
    begin
      yield
    rescue Exception => e
      record.failed!(e)
    else
      record.succeeded!
    end
  end

  def succeeded!
    self.state = 'succeeded'
    self.completed_at = Time.now
    save!
  end

  def failed!(error = nil)
    self.state = 'failed'
    self.error = error.class.name if error
    self.completed_at = Time.now
    save!
  end
end