class AddColumnToCategories < ActiveRecord::Migration
  def up
    add_column :categories, :url_name, :string
    Category.reset_column_information
    Category.all.each do |category|
      category.update_attribute(:url_name, category.name.parameterize )
    end
  end

  def down
    remove_column :categories, :url_name
  end
end
