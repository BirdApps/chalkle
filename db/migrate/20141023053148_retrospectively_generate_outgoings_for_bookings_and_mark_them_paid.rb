class RetrospectivelyGenerateOutgoingsForBookingsAndMarkThemPaid < ActiveRecord::Migration
  def up
    bookings = Booking.need_outgoing_payments
    bookings.each do |booking|
      teacher_payment = OutgoingPayment.pending_payment_for_teacher(booking.teacher) unless booking.teacher_payment
      provider_payment = OutgoingPayment.pending_payment_for_provider(booking.provider) unless booking.provider_payment
      if teacher_payment
        booking.update_column('teacher_payment_id', teacher_payment.id)
      end
      if provider_payment
        booking.update_column('provider_payment_id', provider_payment.id)
      end
      puts "booking #{booking.id} outgoings calculated"
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
