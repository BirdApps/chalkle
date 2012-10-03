class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.integer :category_id
      t.integer :teacher_id
      t.integer :meetup_id
      t.string :name
      t.string :status
      t.text :description
      t.decimal :cost, :default => 0, :precision => 8, :scale => 2
      t.datetime :start_at
      t.integer :duration
      t.text :meetup_data
      t.timestamps
    end
  end
end
