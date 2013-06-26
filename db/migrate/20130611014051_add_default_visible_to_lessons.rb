class AddDefaultVisibleToLessons < ActiveRecord::Migration
  def change
  	change_column :lessons, :visible, :boolean, :default => true
  end
end
