class RemoveBookingIdFromOutgoingPayments < ActiveRecord::Migration
  def change
    remove_column :outgoing_payments, :booking_id
  end
end
