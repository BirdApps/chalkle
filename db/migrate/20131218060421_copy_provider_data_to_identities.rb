class CopyProviderDataToIdentities < ActiveRecord::Migration
  class OmniauthIdentity < ActiveRecord::Base
  end

  class Chalkler < ActiveRecord::Base
  end

  def up
    OmniauthIdentity.all.each do |identity|
      chalkler = Chalkler.find(identity.user_id)
      identity.provider_data = chalkler.meetup_data
      identity.save!
    end
  end

  def down
    OmniauthIdentity.all.each do |identity|
      chalkler = Chalkler.find(identity.user_id)
      chalkler.meetup_data = identity.provider_data
      chalkler.save!
    end
  end
end
