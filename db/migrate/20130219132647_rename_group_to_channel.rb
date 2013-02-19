class RenameGroupToChannel < ActiveRecord::Migration
  def up
    rename_table :groups, :channels

    rename_table :group_admins, :channel_admins
    rename_column :channel_admins, :group_id, :channel_id
    remove_index :channel_admins, :group_admins
    add_index(:channel_admins, [:channel_id, :admin_user_id], :unique => true)

    rename_table :group_lessons, :channel_lessons
    rename_column :channel_lessons, :group_id, :channel_id
    remove_index :channel_lessons, :group_lessons
    add_index(:channel_lessons, [:channel_id, :lesson_id], :unique => true)

    rename_table :group_chalklers, :channel_chalklers
    rename_column :channel_chalklers, :group_id, :channel_id
    remove_index :channel_lessons, :group_chalklers
    add_index(:channel_chalklers, [:channel_id, :chalkler_id], :unique => true)

    rename_table :group_categories, :channel_categories
    rename_column :channel_categories, :group_id, :channel_id
    remove_index :channel_categories, :group_categories
    add_index(:channel_categories, [:channel_id, :category_id], :unique => true)
  end

  def down
    rename_table :channels, :groups

    rename_table :channel_admins, :group_admins
    rename_column :group_admins, :channel_id, :group_id
    remove_index :group_admins, :channel_admins
    add_index(:group_admins, [:group_id, :admin_user_id], :unique => true)

    rename_table :channel_lessons, :group_lessons
    rename_column :group_lessons, :channel_id, :group_id
    remove_index :group_lessons, :channel_lessons
    add_index(:group_lessons, [:group_id, :lesson_id], :unique => true)

    rename_table :channel_chalklers, :group_chalklers
    rename_column :group_chalklers, :channel_id, :group_id
    remove_index :group_chalklers, :channel_chalklers
    add_index(:group_chalklers, [:group_id, :chalkler_id], :unique => true)

    rename_table :channel_categories, :group_categories
    rename_column :group_categories, :channel_id, :group_id
    remove_index :group_categories, :channel_categories
    add_index(:group_categories, [:group_id, :category_id], :unique => true)
  end
end
