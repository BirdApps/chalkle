class AddBookingCompletedMailerSentToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :booking_completed_mailer_sent, :boolean, default: false
    Booking.reset_column_information
    Booking.all.each{|b| b.update_column :booking_completed_mailer_sent, true }
  end
end
