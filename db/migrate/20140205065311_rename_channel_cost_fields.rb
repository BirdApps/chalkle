class RenameChannelCostFields < ActiveRecord::Migration
  def up
    rename_column :channels, :channel_percentage, :channel_rate_override
    change_column :channels, :channel_rate_override, :decimal, :precision => 8, :scale => 4, :default => nil
    execute "UPDATE channels SET channel_rate_override = NULL WHERE cost_model_id IS NULL"
  end

  def down
    change_column :channels, :channel_rate_override, :decimal, :precision => 8, :scale => 4, :default => 0.125
    rename_column :channels, :channel_rate_override, :channel_percentage
  end
end
