class ProviderCategory < ActiveRecord::Base
  validates_uniqueness_of :category_id, :scope => :provider_id
  belongs_to :provider
  belongs_to :category
end
