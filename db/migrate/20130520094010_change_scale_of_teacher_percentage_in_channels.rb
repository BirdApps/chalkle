class ChangeScaleOfTeacherPercentageInChannels < ActiveRecord::Migration
  def change
  	change_column :channels, :teacher_percentage, :decimal, :default => 0.125, :precision => 8, :scale => 4
  end

end
