class AddSwipeDataToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :swipe_transaction_id, :string
    add_column :payments, :swipe_status, :string
    add_column :payments, :swipe_name_on_card, :string
    add_column :payments, :swipe_customer_email, :string
    add_column :payments, :swipe_currency, :string
    add_column :payments, :swipe_identifier_id, :string
    add_column :payments, :swipe_token, :string
  end
end
