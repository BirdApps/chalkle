class AddVenueToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :venue, :text, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :venue, nil }
  end

  def down
  	remove_column :lessons, :venue
  end
end
