class AddLocationToChalkler < ActiveRecord::Migration
  def change
    add_column :chalklers, :location, :string
  end
end
