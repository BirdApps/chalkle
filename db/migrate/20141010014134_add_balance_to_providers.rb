class AddBalanceToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :balance, :decimal
  end
end
