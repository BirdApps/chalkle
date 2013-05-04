class AddAccountToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :account, :string, :default => nil
  end 
end
