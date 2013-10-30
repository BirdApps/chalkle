class AddColourToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :colour_num, :integer
  end
end
