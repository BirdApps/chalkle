class AddEndAtToCourses < ActiveRecord::Migration
  def up
    Lesson.transaction {
      Lesson.all.each{|l| l.update_attribute :duration, 1*60*60 unless l.duration }
    }

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
