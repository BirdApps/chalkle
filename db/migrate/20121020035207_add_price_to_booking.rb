class AddPriceToBooking < ActiveRecord::Migration
  def up
    add_column :bookings, :cost, :decimal, :precision => 8, :scale => 2
    change_column :lessons, :cost, :decimal, :default => nil, :precision => 8, :scale => 2
    change_column :lessons, :teacher_cost, :decimal, :default => nil, :precision => 8, :scale => 2
    Booking.all.each do |b|
      if b.lesson.present? && b.lesson.cost.present?
        b.cost = b.lesson.cost * (1 + b.guests)
        b.save
      end
    end
  end
  def down
    remove_column :bookings, :cost
    change_column :lessons, :cost, :decimal, :default => 0, :precision => 8, :scale => 2
    change_column :lessons, :teacher_cost, :decimal, :default => 0, :precision => 8, :scale => 2
  end
end
