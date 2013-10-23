class EventLog < ActiveRecord::Base
  attr_protected []

  def self.log(name)
    record = self.create!(name: name, started_at: Time.now)
    yield
    record.succeeded!
  end

  def succeeded!
    self.completed_at = Time.now
    save!
  end
end