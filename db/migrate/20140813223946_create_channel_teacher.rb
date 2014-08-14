class CreateChannelTeacher < ActiveRecord::Migration
  def up
    create_table :channel_teachers do |t|
      t.integer :channel_id, null: false
      t.integer :chalkler_id, null: true
      t.string :name, :bio, :pseudo_chalkler_email
      t.boolean :can_make_classes
    end
    add_foreign_key :channel_teachers, :channels
    add_foreign_key :channel_teachers, :chalklers
  end

  def down
    drop_table :channel_teachers
  end
end