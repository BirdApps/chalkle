class AddVenueAddressToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :venue_address, :string
  end
end
