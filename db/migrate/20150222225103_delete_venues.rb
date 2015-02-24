class DeleteVenues < ActiveRecord::Migration
  def up
    drop_table :venues
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
