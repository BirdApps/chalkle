class CreateOutgoingPayments < ActiveRecord::Migration
  def change
    create_table :outgoing_payments do |t|
      t.integer :booking_id
      t.integer :teacher_id
      t.integer :channel_id
      t.datetime :paid_date
      t.decimal :fee
      t.decimal :tax
      t.string :status
      t.string :reference
      t.timestamps
    end
  end
end
