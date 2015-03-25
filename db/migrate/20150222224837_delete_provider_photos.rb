class DeleteProviderPhotos < ActiveRecord::Migration
  def up
    drop_table :provider_photos
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
