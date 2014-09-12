class AddFixedOverheadCostToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :fixed_overhead_cost, :decimal
  end
end
