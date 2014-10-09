class AddIndexToLessons < ActiveRecord::Migration
  def change
    add_index :lessons, :course_id
    add_index :lessons, :start_at
    
  end
end
