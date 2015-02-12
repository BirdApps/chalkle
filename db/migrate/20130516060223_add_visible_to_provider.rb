class AddVisibleToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :visible, :boolean
  end
end
