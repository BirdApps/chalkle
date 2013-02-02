class AddLearningOutcomesToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :learning_outcomes, :text, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :learning_outcomes, nil }
  end

  def down
  	remove_column :lessons, :learning_outcomes
  end
end
