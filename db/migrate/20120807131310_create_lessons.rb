class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.integer :category_id
      t.integer :teacher_id
      t.integer :meetup_id
      t.string :kind
      t.string :name
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
      t.text :meetup_data
      t.timestamps
    end
  end
end
