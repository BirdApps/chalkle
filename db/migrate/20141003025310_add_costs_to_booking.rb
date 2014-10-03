class AddCostsToBooking < ActiveRecord::Migration
  def up
    Booking.transaction do
      Booking.all.each do |booking|
        if !booking.paid 
          booking.update_attribute(:cost_override, nil)  
        else
          booking.update_attribute(:cost_override, booking.course.cost)
        end
      end

      remove_column :bookings, :paid
      
      rename_column :bookings, :cost_override, :paid

      add_column :bookings, :chalkle_fee, :decimal
      add_column :bookings, :chalkle_gst, :decimal
      add_column :bookings, :chalkle_gst_number, :string
      add_column :bookings, :teacher_fee, :decimal
      add_column :bookings, :teacher_gst, :decimal
      add_column :bookings, :teacher_gst_number, :string
      add_column :bookings, :provider_fee, :decimal
      add_column :bookings, :provider_gst, :decimal
      add_column :bookings, :provider_gst_number, :string
      add_column :bookings, :processing_fee, :decimal
      add_column :bookings, :processing_gst, :decimal
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
