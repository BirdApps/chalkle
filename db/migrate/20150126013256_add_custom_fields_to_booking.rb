class AddCustomFieldsToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :custom_fields, :text
  end
end
