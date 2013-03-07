class AddEmailToChannels < ActiveRecord::Migration
  def up
  	add_column :channels, :email, :string, :default => nil
  end

  def down
  	remove_column :channels, :email
  end
end
