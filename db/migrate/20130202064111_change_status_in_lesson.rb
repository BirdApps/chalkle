class ChangeStatusInLesson < ActiveRecord::Migration
  def change
  	change_column :lessons, :status, :string, :default => "Unreviewed"

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :status, "Published" }
  end

  def down
  	change_column :lessons, :status, :string, :default => nil
  end
end
