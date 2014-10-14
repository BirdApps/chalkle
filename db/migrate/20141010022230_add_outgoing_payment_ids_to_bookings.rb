class AddOutgoingPaymentIdsToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :teacher_payment_id, :integer
    add_column :bookings, :channel_payment_id, :integer
  end
end