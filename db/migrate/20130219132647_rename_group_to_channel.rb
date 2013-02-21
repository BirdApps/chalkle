class RenameGroupToChannel < ActiveRecord::Migration
  def up
    remove_index(:group_admins, :name => 'index_group_admins_on_group_id_and_admin_user_id')
    remove_index(:group_lessons, :name => 'index_group_lessons_on_group_id_and_lesson_id')
    remove_index(:group_chalklers, :name => 'index_group_chalklers_on_group_id_and_chalkler_id')
    remove_index(:group_categories, :name => 'index_group_categories_on_group_id_and_category_id')

    rename_table :groups, :channels

    rename_table :group_admins, :channel_admins
    rename_column :channel_admins, :group_id, :channel_id
    add_index(:channel_admins, [:channel_id, :admin_user_id], :unique => true)

    rename_table :group_lessons, :channel_lessons
    rename_column :channel_lessons, :group_id, :channel_id
    add_index(:channel_lessons, [:channel_id, :lesson_id], :unique => true)

    rename_table :group_chalklers, :channel_chalklers
    rename_column :channel_chalklers, :group_id, :channel_id
    add_index(:channel_chalklers, [:channel_id, :chalkler_id], :unique => true)

    rename_table :group_categories, :channel_categories
    rename_column :channel_categories, :group_id, :channel_id
    add_index(:channel_categories, [:channel_id, :category_id], :unique => true)
  end

  def down
    remove_index(:channel_admins, :name => 'index_channel_admins_on_channel_id_and_admin_user_id')
    remove_index(:channel_lessons, :name => 'index_channel_lessons_on_channel_id_and_lesson_id')
    remove_index(:channel_chalklers, :name => 'index_channel_chalklers_on_channel_id_and_chalkler_id')
    remove_index(:channel_categories, :name => 'index_channel_categories_on_channel_id_and_category_id')

    rename_table :channels, :groups

    rename_table :channel_admins, :group_admins
    rename_column :group_admins, :channel_id, :group_id
    add_index(:group_admins, [:group_id, :admin_user_id], :unique => true)

    rename_table :channel_lessons, :group_lessons
    rename_column :group_lessons, :channel_id, :group_id
    add_index(:group_lessons, [:group_id, :lesson_id], :unique => true)

    rename_table :channel_chalklers, :group_chalklers
    rename_column :group_chalklers, :channel_id, :group_id
    add_index(:group_chalklers, [:group_id, :chalkler_id], :unique => true)

    rename_table :channel_categories, :group_categories
    rename_column :group_categories, :channel_id, :group_id
    add_index(:group_categories, [:group_id, :category_id], :unique => true)
  end
end
