class CreateProviderRegions < ActiveRecord::Migration
  def up
    create_table :provider_regions do |t|
      t.integer :provider_id, :region_id
    end
    add_index :provider_regions, [:provider_id, :region_id], unique: true
    add_foreign_key :provider_regions, :providers
    add_foreign_key :provider_regions, :regions
  end

  def down
    drop_table :provider_regions
  end
end
