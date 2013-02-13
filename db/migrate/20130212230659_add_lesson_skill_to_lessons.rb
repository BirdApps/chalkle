class AddLessonSkillToLessons < ActiveRecord::Migration
  def up
  	add_column :lessons, :lesson_skill, :string, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :lesson_skill, nil }
  end

  def down
  	remove_column :lessons, :lesson_skill
  end
end
