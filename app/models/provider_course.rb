class ProviderCourse < ActiveRecord::Base
  validates_uniqueness_of :course_id, :scope => :provider_id
  belongs_to :provider
  belongs_to :course
end
