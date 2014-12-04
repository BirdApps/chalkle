class CourseUnreviewedToDraft < ActiveRecord::Migration
  def up
    Course.where(status: "Unreviewed").update_all(status: "Draft")
    change_column :courses, :status, :string, :default => "Draft"
  end

  def down
    change_column :courses, :status, :string, :default => "Unreviewed"
  end
end
