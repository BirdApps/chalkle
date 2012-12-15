class AddVisibleScopeToPayment < ActiveRecord::Migration
  def up
    add_column :payments, :visible, :boolean
  end

  def down
    remove_column :payments, :visible
  end
end
