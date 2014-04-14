class AddUrlNameToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :url_name, :string
  end
end
