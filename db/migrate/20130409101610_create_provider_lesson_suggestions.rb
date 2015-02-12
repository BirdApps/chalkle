class CreateProviderLessonSuggestions < ActiveRecord::Migration
  def change
    create_table :provider_lesson_suggestions, :id => false do |t|
      t.references :provider, :null => false
      t.references :lesson_suggestion, :null => false
    end

    add_index(:provider_lesson_suggestions, [:provider_id, :lesson_suggestion_id], :unique => true, :name => "cha_les_sug_index")
  end
end
