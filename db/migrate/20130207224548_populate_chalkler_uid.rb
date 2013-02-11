class PopulateChalklerUid < ActiveRecord::Migration
  def up
    Chalkler.all.each { |c| c.update_attribute :uid, c.meetup_id }
  end

  def down
    Chalkler.all.each { |c| c.update_attribute :uid, nil }
  end
end
