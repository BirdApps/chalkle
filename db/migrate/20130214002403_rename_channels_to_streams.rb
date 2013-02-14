class RenameChannelsToStreams < ActiveRecord::Migration
	def self.up
	    rename_table :channels, :streams
	end 
	def self.down
	    rename_table :streams, :channels
	end
end
