class AddRegionColumnToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :region, :string
  end
end
