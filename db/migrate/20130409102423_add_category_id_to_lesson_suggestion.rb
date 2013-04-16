class AddCategoryIdToLessonSuggestion < ActiveRecord::Migration
  def change
    add_column :lesson_suggestions, :category_id, :integer
  end
end
