class CreateChannelPhotos < ActiveRecord::Migration
  def change
    create_table :channel_photos do |t|
      t.integer :channel_id
      t.string :image
      t.timestamps
    end
  end
end
