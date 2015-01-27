class TransferFkFromPaymentToBooking < ActiveRecord::Migration
  def up
    add_reference :bookings, :payments
    Payment.all.map do |payment|
      payment.booking.update_column "payment_id"  
    end
  end

  def down
  end
end
