class ChangeScaleOfTeacherPercentageInProviders < ActiveRecord::Migration
  def change
  	change_column :providers, :teacher_percentage, :decimal, :default => 0.125, :precision => 8, :scale => 4
  end

end
