class AddChannelPercentageOverrideToLessons < ActiveRecord::Migration
  def up
  	add_column :lessons, :channel_percentage_override, :decimal, :default => nil, :precision => 8, :scale => 2

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :channel_percentage_override, nil }
  end

  def down
  	remove_column :lessons, :channel_percentage_override
  end
end
