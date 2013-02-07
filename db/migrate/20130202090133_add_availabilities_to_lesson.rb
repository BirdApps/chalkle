class AddAvailabilitiesToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :availabilities, :text, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :availabilities, nil }
  end

  def down
  	remove_column :lessons, :availabilities
  end
end
