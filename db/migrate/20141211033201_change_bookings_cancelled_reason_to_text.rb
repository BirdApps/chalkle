class ChangeBookingsCancelledReasonToText < ActiveRecord::Migration
  def change
  change_column :bookings, :cancelled_reason, :text 
  end
end
