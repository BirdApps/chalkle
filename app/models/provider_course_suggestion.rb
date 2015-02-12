class ProviderCourseSuggestion < ActiveRecord::Base
  validates_uniqueness_of :provider_id, :scope => :course_suggestion_id

  belongs_to :provider
  belongs_to :course_suggestion
end
