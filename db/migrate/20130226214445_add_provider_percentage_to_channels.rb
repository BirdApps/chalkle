class AddProviderPercentageToProviders < ActiveRecord::Migration
  def up
  	add_column :providers, :provider_percentage, :decimal, :default => 0.125, :precision => 8, :scale => 2

  	Provider.reset_column_information

    Provider.all.each { |l| l.update_attribute :provider_percentage, 0 }
  end

  def down
  	remove_column :providers, :provider_percentage
  end
end
