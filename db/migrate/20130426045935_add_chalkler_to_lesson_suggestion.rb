class AddChalklerToLessonSuggestion < ActiveRecord::Migration
  def change
    change_table :lesson_suggestions do |t|
      t.references :chalkler
    end
  end
end
