class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.integer :chalkler_id
      t.datetime :created_at
    end

    add_foreign_key :filters, :chalklers, unique: true
  end
end
