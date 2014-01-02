class CreateChannelRegions < ActiveRecord::Migration
  def up
    create_table :channel_regions do |t|
      t.integer :channel_id, :region_id
    end
    add_index :channel_regions, [:channel_id, :region_id], unique: true
    add_foreign_key :channel_regions, :channels
    add_foreign_key :channel_regions, :regions
  end

  def down
    drop_table :channel_regions
  end
end
