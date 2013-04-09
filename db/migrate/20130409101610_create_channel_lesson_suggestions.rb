class CreateChannelLessonSuggestions < ActiveRecord::Migration
  def change
    create_table :channel_lesson_suggestions do |t|
      t.integer :channel_id
      t.integer :lesson_suggestion_id

      t.timestamps
    end
  end
end
