class AddEndAtToCourses < ActiveRecord::Migration
  def up
    add_column :courses, :end_at, :datetime
    Course.reset_column_information
    Course.all.each do |course|
      course.end_at!
    end
  end

  def down
    remove_column :courses, :end_at
  end
end
