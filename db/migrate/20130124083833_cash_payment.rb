class CashPayment < ActiveRecord::Migration
  def up
  	add_column :payments, :cash_payment, :boolean

  	Payment.reset_column_information

    Payment.all.each { |p| p.update_attribute :cash_payment, false }
  end

  def down
  	remove_column :payments, :cash_payment
  end
end
