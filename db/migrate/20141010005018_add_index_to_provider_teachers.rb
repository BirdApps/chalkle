class AddIndexToProviderTeachers < ActiveRecord::Migration
  def change
    add_index :provider_teachers, [:provider_id, :chalkler_id]
  end
end
