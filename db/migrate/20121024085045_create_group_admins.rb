class CreateGroupAdmins < ActiveRecord::Migration
  def self.up
    create_table :group_admins, :id => false do |t|
      t.references :group, :null => false
      t.references :admin_user, :null => false
    end

    add_index(:group_admins, [:group_id, :admin_user_id], :unique => true)
  end

  def self.down
    drop_table :group_admins
  end
end
