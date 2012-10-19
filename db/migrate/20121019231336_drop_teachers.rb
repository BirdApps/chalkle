class DropTeachers < ActiveRecord::Migration
  def up
    drop_table :teachers
  end

  def down
    create_table :teachers do |t|
      t.string :name
      t.text :qualification

      t.timestamps
    end
  end
end
