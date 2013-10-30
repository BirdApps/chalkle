class SetDefaultCategoryColour < ActiveRecord::Migration
  def up
    execute "UPDATE categories SET colour_num = 1"
  end

  def down
    execute "UPDATE categories SET colour_num = NULL"
  end
end
