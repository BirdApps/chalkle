class AddCancelledReasonToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :cancelled_reason, :string
  end
end
