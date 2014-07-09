class AddCourses < ActiveRecord::Migration
  def up
      lesson_start_times = Hash.new
      Lesson.all.each do |c|
        lesson_start_times[c.id] = [ c.start_at, c.duration ]
      end

      rename_table :lessons, :courses
    
      create_table :lessons do |t|
        t.integer :course_id
        t.datetime :start_at
        t.decimal :duration
      end

      Lesson.reset_column_information

      lesson_start_times.each do |course_id, params|
        Lesson.create start_at: params[0], duration: params[1], course_id: course_id
      end
    

      remove_column :courses, :start_at
      remove_column :courses, :duration
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end