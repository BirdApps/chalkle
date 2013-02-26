class CreateLessonImages < ActiveRecord::Migration
  def change
    create_table :lesson_images do |t|
      t.string  "title"
      t.integer "pointsize"
      t.timestamps
    end
  end
end
