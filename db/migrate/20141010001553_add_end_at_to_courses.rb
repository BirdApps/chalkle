class AddEndAtToCourses < ActiveRecord::Migration
  def up
    Lesson.transaction do
      Lesson.all.each do |l| 
        unless l.duration
          l.update_attribute :duration, 1*60*60  
          puts "LESSON #{lesson.id} duration inferred at 1 hour.\n"
        end
      end
    end

    add_column :courses, :end_at, :datetime
    Course.reset_column_information
    Course.transaction do
      Course.all.each do |course|
        course.end_at!
        puts "COURSE #{course.id} end_at set.\n"
      end
    end
  end

  def down
    remove_column :courses, :end_at
  end
end
