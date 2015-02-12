class RenameGroupToProvider < ActiveRecord::Migration
  def up
    remove_index(:group_admins, :name => 'index_group_admins_on_group_id_and_admin_user_id')
    remove_index(:group_lessons, :name => 'index_group_lessons_on_group_id_and_lesson_id')
    remove_index(:group_chalklers, :name => 'index_group_chalklers_on_group_id_and_chalkler_id')
    remove_index(:group_categories, :name => 'index_group_categories_on_group_id_and_category_id')

    rename_table :groups, :providers

    rename_table :group_admins, :provider_admins
    rename_column :provider_admins, :group_id, :provider_id
    add_index(:provider_admins, [:provider_id, :admin_user_id], :unique => true)

    rename_table :group_lessons, :provider_lessons
    rename_column :provider_lessons, :group_id, :provider_id
    add_index(:provider_lessons, [:provider_id, :lesson_id], :unique => true)

    rename_table :group_chalklers, :provider_chalklers
    rename_column :provider_chalklers, :group_id, :provider_id
    add_index(:provider_chalklers, [:provider_id, :chalkler_id], :unique => true)

    rename_table :group_categories, :provider_categories
    rename_column :provider_categories, :group_id, :provider_id
    add_index(:provider_categories, [:provider_id, :category_id], :unique => true)
  end

  def down
    remove_index(:provider_admins, :name => 'index_provider_admins_on_provider_id_and_admin_user_id')
    remove_index(:provider_lessons, :name => 'index_provider_lessons_on_provider_id_and_lesson_id')
    remove_index(:provider_chalklers, :name => 'index_provider_chalklers_on_provider_id_and_chalkler_id')
    remove_index(:provider_categories, :name => 'index_provider_categories_on_provider_id_and_category_id')

    rename_table :providers, :groups

    rename_table :provider_admins, :group_admins
    rename_column :group_admins, :provider_id, :group_id
    add_index(:group_admins, [:group_id, :admin_user_id], :unique => true)

    rename_table :provider_lessons, :group_lessons
    rename_column :group_lessons, :provider_id, :group_id
    add_index(:group_lessons, [:group_id, :lesson_id], :unique => true)

    rename_table :provider_chalklers, :group_chalklers
    rename_column :group_chalklers, :provider_id, :group_id
    add_index(:group_chalklers, [:group_id, :chalkler_id], :unique => true)

    rename_table :provider_categories, :group_categories
    rename_column :group_categories, :provider_id, :group_id
    add_index(:group_categories, [:group_id, :category_id], :unique => true)
  end
end
