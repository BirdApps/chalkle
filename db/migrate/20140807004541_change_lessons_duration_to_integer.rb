class ChangeLessonsDurationToInteger < ActiveRecord::Migration
  def up
    change_column :lessons, :duration, :integer 
  end

  def down
    change_column :lessons, :duration, :decimal 
  end
end
