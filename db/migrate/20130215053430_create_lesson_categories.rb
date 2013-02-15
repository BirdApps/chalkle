class CreateLessonCategories < ActiveRecord::Migration
  def up
    create_table :lesson_categories, :id => false do |t|
      t.references :lesson, :null => false
      t.references :category, :null => false
    end

    add_index(:lesson_categories, [:lesson_id, :category_id], :unique => true)

    remove_column :lessons, :category_id
  end

  def down
    drop_table :lesson_categories
    add_column :lessons, :category_id, :integer
    add_index :lessons, :category_id
  end
end
