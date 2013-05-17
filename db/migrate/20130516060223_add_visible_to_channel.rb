class AddVisibleToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :visible, :boolean
  end
end
