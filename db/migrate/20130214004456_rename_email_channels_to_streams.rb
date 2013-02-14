class RenameEmailChannelsToStreams < ActiveRecord::Migration
  def self.up
    rename_column :chalklers, :email_channels, :email_streams
  end

  def down
  	rename_column :chalklers, :email_streams, :email_channels
  end
end
