class Subscription < ActiveRecord::Base
  attr_accessible :chalkler_id, :provider_id, :chalkler, :provider, :pseudo_chalkler_email
  validates_uniqueness_of :chalkler_id, :scope => :provider_id
  belongs_to :provider
  belongs_to :chalkler

  def chalkler?
    chalkler.present?
  end

  def path_params
    {
      provider_url_name: provider,
      id: self
    }
  end
end
