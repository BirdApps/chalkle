class AddDoDuringClassToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :do_during_class, :text, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :do_during_class, nil }
  end

  def down
  	remove_column :lessons, :do_during_class
  end
end
