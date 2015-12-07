class AddPseudoChalklerEmailToSubscription < ActiveRecord::Migration
  def up
    add_column :subscriptions, :pseudo_chalkler_email, :string
    change_column :subscriptions, :chalkler_id, :integer, null: true
  end

  def down
    remove_column :subscriptions, :pseudo_chalkler_email
    change_column :subscriptions, :chalkler_id, :integer, null: false
  end
end
