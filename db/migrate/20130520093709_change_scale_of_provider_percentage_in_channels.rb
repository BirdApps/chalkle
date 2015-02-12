class ChangeScaleOfProviderPercentageInProviders < ActiveRecord::Migration
  def change
  	change_column :providers, :provider_percentage, :decimal, :default => 0.125, :precision => 8, :scale => 4
  end

end
