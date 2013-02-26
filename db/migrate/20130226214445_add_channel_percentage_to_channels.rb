class AddChannelPercentageToChannels < ActiveRecord::Migration
  def up
  	add_column :channels, :channel_percentage, :decimal, :default => 0, :precision => 8, :scale => 2

  	Channel.reset_column_information

    Channel.all.each { |l| l.update_attribute :channel_percentage, 0 }
  end

  def down
  	remove_column :channels, :channel_percentage
  end
end
