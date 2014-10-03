class AddMaxTeachersToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :plan_max_teachers, :integer
  end
end
