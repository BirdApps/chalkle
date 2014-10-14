class AddColumnToChalkler < ActiveRecord::Migration
  def change
    add_column :chalklers, :visible, :boolean, default: true
  end
end
