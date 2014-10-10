class AddIndexToChannelTeachers < ActiveRecord::Migration
  def change
    add_index :channel_teachers, [:channel_id, :chalkler_id]
  end
end
