class AddProviderRateOverrideToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :provider_rate_override, :decimal, :precision => 8, :scale => 4
  end
end
