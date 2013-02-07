class AddLessonTypeToLessons < ActiveRecord::Migration
  def up
  	add_column :lessons, :lesson_type, :string, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :lesson_type, nil }
  end

  def down
  	remove_column :lessons, :lesson_type
  end
end
