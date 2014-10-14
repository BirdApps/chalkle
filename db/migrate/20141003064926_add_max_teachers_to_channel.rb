class AddMaxTeachersToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :plan_max_teachers, :integer unless column_exists? :channels, :plan_max_teachers
  end
end
