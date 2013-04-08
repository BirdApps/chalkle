class AddMaterialCostToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :material_cost, :decimal, :default => 0, :precision => 8, :scale => 2

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :material_cost, 0 }
  end

  def down
  	remove_column :lessons, :material_cost
  end
end
