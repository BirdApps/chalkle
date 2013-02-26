class CreateLessonCategories < ActiveRecord::Migration
  def up
    create_table :lesson_categories, :id => false do |t|
      t.references :lesson, :null => false
      t.references :category, :null => false
    end
    add_index(:lesson_categories, [:lesson_id, :category_id], :unique => true)

  	LessonCategory.reset_column_information
    Lesson.all.each { |l| LessonCategory.create(lesson_id: l.id, category_id: l.category_id) if l.category_id? }

    remove_column :lessons, :category_id
  end

  def down
    drop_table :lesson_categories
    add_column :lessons, :category_id, :integer
    add_index :lessons, :category_id
  end
end