class AddPrimaryColumnToCategories < ActiveRecord::Migration
  def up
    add_column :categories, :primary, :boolean, :default => false
    existing = ['Creative Arts', 'Culture', 'Lifestyle', 'Professional', 'Science & Technology']
    existing.each do |name|
      Category.update_all({primary: true}, {name: name})
    end
  end

  def down
    remove_column :categories, :primary
  end
end
