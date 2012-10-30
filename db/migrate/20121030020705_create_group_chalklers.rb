class CreateGroupChalklers < ActiveRecord::Migration
  def self.up
    create_table :group_chalklers, :id => false do |t|
      t.references :group, :null => false
      t.references :chalkler, :null => false
    end

    add_index(:group_chalklers, [:group_id, :chalkler_id], :unique => true)
  end

  def self.down
    drop_table :group_chalklers
  end
end
