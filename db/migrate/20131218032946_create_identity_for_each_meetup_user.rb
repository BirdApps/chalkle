class CreateIdentityForEachMeetupUser < ActiveRecord::Migration
  class Chalkler < ActiveRecord::Base
  end

  class OmniauthIdentity < ActiveRecord::Base
    attr_accessible :user_id, :provider, :uid
  end

  def up
    Chalkler.where(provider: 'meetup').each do |chalkler|
      OmniauthIdentity.create(user_id: chalkler.id, provider: 'meetup', uid: chalkler.uid)
    end
  end

  def down
  end
end
