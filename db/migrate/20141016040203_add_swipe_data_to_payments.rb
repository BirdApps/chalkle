class AddSwipeDataToPayments < ActiveRecord::Migration
  def change
    add_column :bookings, :swipe_transaction_id, :string
    add_column :bookings, :swipe_status, :string
    add_column :bookings, :swipe_name_on_card, :string
    add_column :bookings, :swipe_customer_email, :string
    add_column :bookings, :swipe_currency, :string
    add_column :bookings, :swipe_td_user_data, :string
    add_column :bookings, :swipe_token, :string
  end
end
