class AddReminderMailerSentToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :reminder_mailer_sent, :boolean, default: false
  end
end
