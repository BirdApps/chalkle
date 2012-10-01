class CreateChalklers < ActiveRecord::Migration
  def change
    create_table :chalklers do |t|
      t.string :name
      t.string :email
      t.integer :meetup_id
      t.text :bio
      t.text :meetup_data

      t.timestamps
    end
  end
end
