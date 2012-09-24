class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.integer :category_id
      t.integer :teacher_id
      t.string :kind
      t.string :title
      t.text :doing
      t.text :learn
      t.integer :skill
      t.string :skill_note
      t.text :bring
      t.string :charge
      t.string :cost
      t.text :note
      t.string :start
      t.string :end
      t.string :link
      t.timestamps
    end
  end
end
