class RemoveRegions < ActiveRecord::Migration
  def up
    remove_column :courses, :region_id
    remove_column :chalklers, :email_region_ids
    drop_table :provider_regions
    drop_table :regions
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
