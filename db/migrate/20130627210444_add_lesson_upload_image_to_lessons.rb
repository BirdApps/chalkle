class AddLessonUploadImageToLessons < ActiveRecord::Migration
  def up
    add_column :lessons, :lesson_upload_image, :string, default: nil
  end

  def down
    remove_column :lessons, :lesson_upload_image
  end
end
