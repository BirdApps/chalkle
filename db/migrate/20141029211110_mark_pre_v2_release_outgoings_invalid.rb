class MarkPreV2ReleaseOutgoingsInvalid < ActiveRecord::Migration
   #ensure all post release bookings are not yet calculated into payment, mark all previously calculated outgoings as invalid
   def up
    Booking.joins(:course).where("courses.start_at > '#{DateTime.new(2014,10,11).to_s(:db)}'").update_all(provider_payment_id: nil, teacher_payment_id: nil)
    OutgoingPayment.update_all(status: "not_valid", reference: "Pre v2 release")
  end

  def down
  end
end
