class TransferFkFromPaymentToBooking < ActiveRecord::Migration
  def up
    add_column :bookings, :payment_id, :integer
    Booking.reset_column_information
    
    add_column :payments, :chalkler_id, :integer
    Payment.reset_column_information

    Booking.transaction do
      Payment.all.map do |payment|
        booking = Booking.find(payment.booking_id) if payment.booking_id
        if booking
          booking.update_column "payment_id", payment.id
          Payment.transaction do
            payment.update_column "chalkler_id", booking.chalkler_id
          end
        end
      end
    end

    remove_column :payments, :booking_id
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
