class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :booking_id
      t.string :xero_id
      t.string :xero_contact_id
      t.string :xero_contact_name
      t.date :date
      t.boolean :complete_record_downloaded
      t.decimal :total, :default => 0, :precision => 8, :scale => 2
      t.boolean :reconciled

      t.timestamps
    end
  end
end
