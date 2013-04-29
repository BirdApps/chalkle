class AddAccountToChannels < ActiveRecord::Migration
  def up
  	add_column :channels, :account, :string, :default => nil
  end

  def down
  	remove_column :channels, :account
  end
end
