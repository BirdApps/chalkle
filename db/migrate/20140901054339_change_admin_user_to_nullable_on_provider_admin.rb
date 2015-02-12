class ChangeAdminUserToNullableOnProviderAdmin < ActiveRecord::Migration
  def change
    change_column :provider_admins, :admin_user_id, :integer, null: true
  end
end
