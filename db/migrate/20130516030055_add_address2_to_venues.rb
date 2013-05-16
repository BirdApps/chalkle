class AddAddress2ToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :address_2, :string
  end
end
