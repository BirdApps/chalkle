class AddDragonflyToLessonImage < ActiveRecord::Migration
  def up
    add_column :lesson_images, :image_uid, :string
    add_column :lesson_images, :image_name, :string
  end

  def down
    remove_column :lesson_images, :image_uid
    remove_column :lesson_images, :image_name
  end
end
