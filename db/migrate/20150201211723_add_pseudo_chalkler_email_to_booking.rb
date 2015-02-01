class AddPseudoChalklerEmailToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :pseudo_chalkler_email, :string
  end
end
