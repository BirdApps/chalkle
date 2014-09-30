class RemoveChannelAdminsWithoutUsers < ActiveRecord::Migration
  #found records of channel_admins with admin_user_ids which referenced deleted admin_users, so deleting those channel_admins without admin_users or chalklers
  def up

    ChannelAdmin.all.map do |channel_admin|
      if channel_admin.chalkler_id.nil?
        admin_user = AdminUser.find_by_id channel_admin.admin_user_id
        if !admin_user
          puts channel_admin.id
          channel_admin.destroy
        end
      end
    end

  end

  def down
  end
end
