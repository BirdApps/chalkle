class CreateChannelLessonSuggestions < ActiveRecord::Migration
  def self.up 
    create_table :channel_lesson_suggestions, :id => false do |t|
      t.references :channel, :null => false
      t.references :lesson_suggestion, :null => false
    end

    add_index(:channel_lesson_suggestions, [:channel_id, :lesson_suggestion_id], :unique => true, :name => "cha_les_sug_index")
  end

  def self.down
    drop_table :channel_lesson_suggestions
  end
end
