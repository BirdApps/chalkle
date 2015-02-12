class RenameProviderCostFields < ActiveRecord::Migration
  def up
    rename_column :providers, :provider_percentage, :provider_rate_override
    change_column :providers, :provider_rate_override, :decimal, :precision => 8, :scale => 4, :default => nil
    execute "UPDATE providers SET provider_rate_override = NULL WHERE cost_model_id IS NULL"
  end

  def down
    change_column :providers, :provider_rate_override, :decimal, :precision => 8, :scale => 4, :default => 0.125
    rename_column :providers, :provider_rate_override, :provider_percentage
  end
end
