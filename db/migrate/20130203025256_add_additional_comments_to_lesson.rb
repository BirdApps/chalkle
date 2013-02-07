class AddAdditionalCommentsToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :additional_comments, :text, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :additional_comments, nil }
  end

  def down
  	remove_column :lessons, :additional_comments
  end
end
