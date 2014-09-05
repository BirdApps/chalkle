class AddStartAtColumnToCourse < ActiveRecord::Migration
  def up
    add_column :courses, :start_at, :datetime
    Course.reset_column_information
    Course.all.each do |course|
      course.update_attribute :start_at, course.first_lesson_start_at
    end
  end

  def down
    remove_column :courses, :start_at
  end
end
