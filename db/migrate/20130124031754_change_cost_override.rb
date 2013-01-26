class ChangeCostOverride < ActiveRecord::Migration
  def up
    change_column :bookings, :cost_override, :decimal, :default => nil, :precision => 8, :scale => 2
    Booking.reset_column_information
    Booking.all.each { |b| b.update_attribute :cost_override, nil }
  end

  def down
    change_column :bookings, :cost_override, :decimal, :default => 0, :precision => 8, :scale => 2
  end
end
