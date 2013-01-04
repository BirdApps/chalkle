class AddVisibleToModels < ActiveRecord::Migration
  def up
    add_column :payments, :visible, :boolean
    add_column :bookings, :visible, :boolean
    add_column :lessons, :visible, :boolean

    Payment.reset_column_information
    Booking.reset_column_information
    Lesson.reset_column_information

    Payment.all.each { |p| p.update_attribute :visible, true }
    Booking.all.each { |b| b.update_attribute :visible, true }
    Lesson.all.each { |l| l.update_attribute :visible, true }
  end

  def down
    remove_column :payments, :visible
    remove_column :bookings, :visible
    remove_column :lessons, :visible
  end
end
