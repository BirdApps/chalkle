class AddVisibleToProviderTeachers < ActiveRecord::Migration
  def change
    add_column :provider_teachers, :visible, :boolean, default: :true, null: false
  end
end
