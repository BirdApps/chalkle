class DeleteStreams < ActiveRecord::Migration
  def up
    drop_table :streams
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
