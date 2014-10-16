class ApplyFeesToHistoricBookings < ActiveRecord::Migration
  def up
    Booking.confirmed.where("created_at < DATE('2014-10-13') AND paid > 0").each do |booking|
      if booking.cost == 0
        cost = booking.apply_fees
        if booking.changed?
          booking.update_column :chalkle_fee, booking.chalkle_fee
          booking.update_column :chalkle_gst, booking.chalkle_gst
          booking.update_column :teacher_fee, booking.teacher_fee
          booking.update_column :teacher_gst, booking.teacher_gst
          booking.update_column :provider_fee, booking.provider_fee
          booking.update_column :provider_gst, booking.provider_gst
          booking.update_column :processing_fee, booking.processing_fee
          booking.update_column :processing_gst, booking.processing_gst
          puts "Booking #{booking.id} fees now #{booking.cost}"
        end
      end
    end
  end


  def down
    ActiveRecord::IrreversibleMigration
  end
end
