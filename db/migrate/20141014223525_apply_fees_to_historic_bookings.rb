class ApplyFeesToHistoricBookings < ActiveRecord::Migration
  def up
    Booking.transaction do
      Booking.confirmed.where("created_at < DATE('2014-10-13')").each do |booking|
        cost = booking.apply_fees
        if booking.changed?
          booking.save
          puts "Booking #{booking.id} fees now #{booking.cost}"
        end
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
