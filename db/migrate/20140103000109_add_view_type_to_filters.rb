class AddViewTypeToFilters < ActiveRecord::Migration
  def change
    add_column :filters, :view_type, :string, length: 10, default: 'weeks'
  end
end
