class AddPrerequisitesToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :prerequisites, :text, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :prerequisites, nil }
  end

  def down
  	remove_column :lessons, :prerequisites
  end
end
