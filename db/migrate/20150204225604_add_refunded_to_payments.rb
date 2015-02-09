class AddRefundedToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :refunded, :decimal, default: 0
    Payment.reset_column_information
    Payment.scoped.update_all(refunded: 0)
  end
end
