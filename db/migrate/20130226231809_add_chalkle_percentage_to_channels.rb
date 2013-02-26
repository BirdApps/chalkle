class AddChalklePercentageToChannels < ActiveRecord::Migration
  def up
  	add_column :channels, :chalkle_percentage, :decimal, :default => 0.125, :precision => 8, :scale => 2

  	Channel.reset_column_information

    Channel.all.each { |l| l.update_attribute :chalkle_percentage, 0.0 }
  end

  def down
  	remove_column :channels, :chalkle_percentage
  end
end
