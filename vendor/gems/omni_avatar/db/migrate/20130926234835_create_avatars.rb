class CreateAvatars < ActiveRecord::Migration
  def change
    create_table :omni_avatar_avatars do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string :image
      t.string :provider_name
      t.string :original_url
    end
  end
end
