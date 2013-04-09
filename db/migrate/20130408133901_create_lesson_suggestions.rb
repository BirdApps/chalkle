class CreateLessonSuggestions < ActiveRecord::Migration
  def change
    create_table :lesson_suggestions do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
