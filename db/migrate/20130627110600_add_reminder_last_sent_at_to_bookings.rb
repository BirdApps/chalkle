class AddReminderLastSentAtToBookings < ActiveRecord::Migration
  def up
    add_column :bookings, :reminder_last_sent_at, :datetime, default: nil
  end

  def down
    remove_column :bookings, :reminder_last_sent_at
  end 
end
