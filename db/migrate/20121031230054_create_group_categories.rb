class CreateGroupCategories < ActiveRecord::Migration
  def self.up
    create_table :group_categories, :id => false do |t|
      t.references :group, :null => false
      t.references :category, :null => false
    end

    add_index(:group_categories, [:group_id, :category_id], :unique => true)
  end

  def self.down
    drop_table :group_categories
  end
end
