class RetrospectivelyGenerateOutgoingsForBookingsAndMarkThemPaid < ActiveRecord::Migration
  def up
    bookings = Booking.need_outgoing_payments
    bookings.each do |booking|
      teacher_payment = OutgoingPayment.pending_payment_for_teacher(booking.teacher) unless booking.teacher_payment
      channel_payment = OutgoingPayment.pending_payment_for_channel(booking.channel) unless booking.channel_payment
      if teacher_payment
        booking.update_column('teacher_payment_id', teacher_payment.id)
        teacher_payment.update_column('status', 'marked_paid')
      end
      if channel_payment
        booking.update_column('channel_payment_id', channel_payment.id)
        channel_payment.update_column('status', 'marked_paid')
      end
      puts "booking #{booking.id} outgoings calculated"
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
