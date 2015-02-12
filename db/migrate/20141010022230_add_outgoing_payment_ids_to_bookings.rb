class AddOutgoingPaymentIdsToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :teacher_payment_id, :integer
    add_column :bookings, :provider_payment_id, :integer
  end
end