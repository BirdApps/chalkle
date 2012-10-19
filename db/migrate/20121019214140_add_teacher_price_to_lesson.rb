class AddTeacherPriceToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :teacher_cost, :decimal, :default => 0, :precision => 8, :scale => 2
  end
end
