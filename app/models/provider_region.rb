class ProviderRegion < ActiveRecord::Base
  belongs_to :provider
  belongs_to :region
end