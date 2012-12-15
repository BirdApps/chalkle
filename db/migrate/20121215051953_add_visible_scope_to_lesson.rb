class AddVisibleScopeToLesson < ActiveRecord::Migration
  def up
    add_column :lessons, :visible, :boolean
  end

  def down
    remove_column :lessons, :visible
  end
end
