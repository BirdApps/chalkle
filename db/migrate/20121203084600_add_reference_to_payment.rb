class AddReferenceToPayment < ActiveRecord::Migration
  def up
    add_column :payments, :reference, :string
  end

  def down
    remove_column :payments, :reference
  end
end
