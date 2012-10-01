class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.integer :meetup_id
      t.integer :lesson_id
      t.integer :chalkler_id
      t.string :status
      t.integer :guests
      t.boolean :paid
      t.text :meetup_data

      t.timestamps
    end
  end
end
