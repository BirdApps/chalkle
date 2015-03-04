class Subscription < ActiveRecord::Base
  attr_accessible :chalkler_id, :provider_id, :chalkler, :provider
  validates_uniqueness_of :chalkler_id, :scope => :provider_id
  belongs_to :provider
  belongs_to :chalkler

  def path_params
    {
      provider_url_name: provider,
      id: self
    }
  end
end
