class AddTeacherBioToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :teacher_bio, :text, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :teacher_bio, nil }
  end

  def down
  	remove_column :lessons, :teacher_bio
  end
end
