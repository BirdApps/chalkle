class CreateProviderPhotos < ActiveRecord::Migration
  def change
    create_table :provider_photos do |t|
      t.integer :provider_id
      t.string :image
      t.timestamps
    end
  end
end
