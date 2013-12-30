class AddChannelIdToLessons < ActiveRecord::Migration
  def change
  	add_column :lessons, :channel_id, :integer
  end
end
