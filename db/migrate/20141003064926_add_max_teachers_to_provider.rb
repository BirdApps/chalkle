class AddMaxTeachersToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :plan_max_teachers, :integer unless column_exists? :providers, :plan_max_teachers
  end
end
