class AddSwipeIdentifierToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :swipe_identifier, :string
  end
end
