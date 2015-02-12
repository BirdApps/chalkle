class RenameProvidersToStreams < ActiveRecord::Migration
	def self.up
	    rename_table :providers, :streams
	end 
	def self.down
	    rename_table :streams, :providers
	end
end
