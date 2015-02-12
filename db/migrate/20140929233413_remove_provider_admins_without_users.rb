class RemoveProviderAdminsWithoutUsers < ActiveRecord::Migration
  #found records of provider_admins with admin_user_ids which referenced deleted admin_users, so deleting those provider_admins without admin_users or chalklers
  def up

    ProviderAdmin.all.map do |provider_admin|
      if provider_admin.chalkler_id.nil?
        admin_user = AdminUser.find_by_id provider_admin.admin_user_id
        if !admin_user
          puts provider_admin.id
          provider_admin.destroy
        end
      end
    end

  end

  def down
  end
end
