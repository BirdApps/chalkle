class AddTeacherPercentageToChannels < ActiveRecord::Migration
  def up
  	add_column :channels, :teacher_percentage, :decimal, :default => 0.8, :precision => 8, :scale => 2

  	Channel.reset_column_information

    Channel.all.each { |l| l.update_attribute :teacher_percentage, 0.8 }
  end

  def down
  	remove_column :channels, :teacher_percentage
  end
end
