class AddCourseClassTypeToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :course_class_type, :string
  end
end
