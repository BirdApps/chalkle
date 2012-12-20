class AddVisibleToModels < ActiveRecord::Migration
  def up
    add_column :payments, :visible, :boolean
    add_column :bookings, :visible, :boolean
    add_column :lessons, :visible, :boolean
  end

  def down
    remove_column :payments, :visible
    remove_column :bookings, :visible
    remove_column :lessons, :visible
  end
end
