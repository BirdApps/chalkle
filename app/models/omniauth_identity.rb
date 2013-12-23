class OmniauthIdentity < ActiveRecord::Base
  belongs_to :user, class_name: 'Chalkler'

  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, scope: :provider

  attr_accessible :uid, :provider

  serialize :provider_data, JSON

  def self.from_omniauth(auth)
    result = where(uid: auth[:uid].to_s, provider: auth[:provider].to_s).first_or_create do |record|
      record.email = auth.info.email
      record.name = auth.info.name
    end
    result.provider_data = auth
    result.email = auth.info.email
    result.name = auth.info.name
    result.save!
    result
  end
end
