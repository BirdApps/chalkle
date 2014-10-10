class AddAccountInformationToOutgoingPayments < ActiveRecord::Migration
  def change
    add_column :outgoing_payments, :bank_account, :string
    add_column :outgoing_payments, :tax_number, :string
  end
end
