
class AddRegionIdToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :region_id, :integer
    add_foreign_key :lessons, :regions
  end
end
