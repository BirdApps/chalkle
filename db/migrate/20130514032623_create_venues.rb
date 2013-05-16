class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name, :null => false
      t.integer :meetup_id
      t.string :address_1, :null => false
      t.float :lat, :precision => 6, :scale => 10
      t.float :lon, :precision => 6, :scale => 10
      t.references :city, :null => false
      t.timestamps
    end
  end
end
