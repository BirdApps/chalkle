class CreateGroupLessons < ActiveRecord::Migration
  def self.up
    create_table :group_lessons, :id => false do |t|
      t.references :group, :null => false
      t.references :lesson, :null => false
    end

    add_index(:group_lessons, [:group_id, :lesson_id], :unique => true)
  end

  def self.down
    drop_table :group_lessons
  end
end
