class AddTeacherPercentageToProviders < ActiveRecord::Migration
  def up
  	add_column :providers, :teacher_percentage, :decimal, :default => 0.75, :precision => 8, :scale => 2

  	Provider.reset_column_information

    Provider.all.each { |l| l.update_attribute :teacher_percentage, 0.8 }
  end

  def down
  	remove_column :providers, :teacher_percentage
  end
end
