class AdminsTeachersFollowTheirProviders < ActiveRecord::Migration
  def up
    Chalkler.scoped.each do |chalkler|
      chalkler.providers_teachable.each do |provider|
        unless chalkler.providers_following.include? provider
          Subscription.create chalkler: chalkler, provider: provider
        end
      end
      chalkler.providers_adminable.each do |provider|
        unless chalkler.providers_following.include? provider
          Subscription.create chalkler: chalkler, provider: provider
        end
      end
    end
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
