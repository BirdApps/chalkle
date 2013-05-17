class SetVisibleToFalseOnChannels < ActiveRecord::Migration
  def change
    change_column :channels, :visible, :boolean, :default => false
  end
end
