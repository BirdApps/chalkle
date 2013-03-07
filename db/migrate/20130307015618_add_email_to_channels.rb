class AddEmailToChannels < ActiveRecord::Migration
  def up
  	add_column :channels, :email, :string, :default => nil

  	Channel.reset_column_information

    Channel.all.each { |l| l.update_attribute :email, nil }
  end

  def down
  	remove_column :channels, :email
  end
end
