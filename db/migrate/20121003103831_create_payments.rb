class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :xero_id
      t.integer :booking_id
      t.integer :chalkler_id
      t.boolean :reconciled
      t.text :xero_data

      t.timestamps
    end
  end
end
