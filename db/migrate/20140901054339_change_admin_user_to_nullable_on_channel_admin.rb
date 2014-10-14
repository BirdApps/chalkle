class ChangeAdminUserToNullableOnChannelAdmin < ActiveRecord::Migration
  def change
    change_column :channel_admins, :admin_user_id, :integer, null: true
  end
end
