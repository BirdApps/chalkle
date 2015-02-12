class SetVisibleToFalseOnProviders < ActiveRecord::Migration
  def change
    change_column :providers, :visible, :boolean, :default => false
  end
end
