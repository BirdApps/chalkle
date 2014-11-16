class CourseUnreviewedToDraft < ActiveRecord::Migration
  def up
    Course.where(status: "Unreviewed").update_all(status: "Draft")
  end

  def down
  end
end
