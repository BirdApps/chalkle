class AddBalanceToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :balance, :decimal
  end
end
