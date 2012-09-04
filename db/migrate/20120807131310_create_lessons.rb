class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.integer :category_id
      t.string :kind
      t.string :title
      t.text :doing
      t.text :learn
      t.integer :skill
      t.string :skill_note
      t.string :teacher_name
      t.text :teacher_qualification
      t.text :bring
      t.string :charge
      t.string :cost
      t.string :book
      t.text :note
      t.string :start
      t.string :end
      t.string :link
      t.timestamps
    end
  end
end
