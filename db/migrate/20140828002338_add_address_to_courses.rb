class AddAddressToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :street_number, :string
    add_column :courses, :street_name, :string
    add_column :courses, :city, :string
    add_column :courses, :postal_code, :string
    add_column :courses, :longitude, :float
    add_column :courses, :latitude, :float
  end
end
