class RemoveAdminuser < ActiveRecord::Migration
  def up
    add_column :chalklers, :role, :string
    Chalkler.reset_column_information

    supers = ["anthony@chalkle.com", "silvia@chalkle.com", "matthew.kerr@me.com","jdbdean@gmail.com"]
    supers.each do |super_email|
      chalkler =  Chalkler.find_by_email super_email
      chalkler.update_column('role', 'super') if chalkler
    end

    drop_table :admin_users
    remove_column :channel_admins, :admin_user_id
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
