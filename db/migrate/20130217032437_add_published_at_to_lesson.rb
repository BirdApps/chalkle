class AddPublishedAtToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :published_at, :datetime, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :published_at, l.created_at if l.status=="Published" }
  end

  def down
  	remove_column :lessons, :published_at
  end
end
