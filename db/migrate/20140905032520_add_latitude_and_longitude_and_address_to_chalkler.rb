class AddLatitudeAndLongitudeAndAddressToChalkler < ActiveRecord::Migration
  def change
    add_column :chalklers, :latitude, :float
    add_column :chalklers, :longitude, :float
    add_column :chalklers, :address, :string
  end
end
