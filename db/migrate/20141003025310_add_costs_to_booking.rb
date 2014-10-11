class AddCostsToBooking < ActiveRecord::Migration
  def up
    Booking.transaction do
      Booking.all.each do |booking|
        if !booking.paid 
          booking.update_column(:cost_override, nil)  
          puts "#{booking.id}: not paid\n"
        else
          unless booking.cost_override
            booking.update_column(:cost_override, booking.course.cost)
            puts "#{booking.id}: course cost not overriden: #{booking.course.cost} \n"
          end
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
