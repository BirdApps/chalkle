class RenameEmailProvidersToStreams < ActiveRecord::Migration
  def self.up
    rename_column :chalklers, :email_providers, :email_streams
  end

  def down
  	rename_column :chalklers, :email_streams, :email_providers
  end
end
