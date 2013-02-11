class PopulateChalklerProvider < ActiveRecord::Migration
  def up
    Chalkler.all.each { |c| c.update_attribute :provider, c.meetup_id.present? ? "meetup" : nil }
  end

  def down
    Chalkler.all.each { |c| c.update_attribute :provider, nil }
  end
end
