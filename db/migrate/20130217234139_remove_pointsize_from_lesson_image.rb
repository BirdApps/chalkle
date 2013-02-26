class RemovePointsizeFromLessonImage < ActiveRecord::Migration
  def up
    remove_column :lesson_images, :pointsize
  end

  def down
    add_column :lesson_images, :pointsize, :int
  end
end
