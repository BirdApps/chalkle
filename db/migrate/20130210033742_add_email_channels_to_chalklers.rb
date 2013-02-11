class AddEmailChannelsToChalklers < ActiveRecord::Migration
  def up
  	add_column :chalklers, :email_channels, :text
  end

  def down
  	remove_column :chalklers, :email_channels
  end
end
