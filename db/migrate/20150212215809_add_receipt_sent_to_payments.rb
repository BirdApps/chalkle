class AddReceiptSentToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :receipt_sent, :boolean, default: false
    Payment.reset_column_information
    Payment.update_all :receipt_sent => true
  end
end
