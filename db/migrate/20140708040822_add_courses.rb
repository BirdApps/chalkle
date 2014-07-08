class AddCourses < ActiveRecord::Migration
  def up
      rename_table :lessons, :courses
      
      Course.reset_column_information

      create_table :lessons do |t|
        t.integer :course_id
        t.datetime :start_at
        t.decimal :duration
      end

      Course.all.each do |c|
        Lesson.create start_at: c.start_at, duration: c.duration, course_id: c.course_id
      end
    

      remove_column :courses, :start_at
      remove_column :courses, :duration
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end