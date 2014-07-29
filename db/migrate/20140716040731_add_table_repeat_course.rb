class AddTableRepeatCourse < ActiveRecord::Migration
  def up
    create_table :repeat_courses
    add_column :courses, :repeat_course_id, :integer
  end

  def down
    remove_column :courses, :repeat_course_id
    drop_table :repeat_courses
  end
end
