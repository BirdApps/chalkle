class AddLessonAssociationToLessonImage < ActiveRecord::Migration
  def up
    add_column :lesson_images, :lesson_id, :int
  end

  def down
    remove_column :lesson_images, :lesson_id
  end
end
