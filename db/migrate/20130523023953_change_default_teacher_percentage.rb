class ChangeDefaultTeacherPercentage < ActiveRecord::Migration
  def change
  	change_column :channels, :teacher_percentage, :decimal, :default => 0.75, :precision => 8, :scale => 4
  end

end
