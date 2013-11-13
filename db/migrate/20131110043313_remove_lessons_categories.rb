class RemoveLessonsCategories < ActiveRecord::Migration
  def up
    drop_table "lesson_categories"
  end

  def down
    create_table "lesson_categories", :id => false, :force => true do |t|
      t.integer "lesson_id",   :null => false
      t.integer "category_id", :null => false
    end

    add_index "lesson_categories", ["lesson_id", "category_id"], :name => "index_lesson_categories_on_lesson_id_and_category_id", :unique => true
  end
end
