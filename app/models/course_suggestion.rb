class CourseSuggestion < ActiveRecord::Base
  attr_accessible :description, :name, :category_id, :join_providers
  attr_accessible :description, :name, :category_id, :join_providers, :chalkler_id, :provider_ids, :as => :admin

  attr_accessor :join_providers

  belongs_to :chalkler
  belongs_to :category
  has_many :provider_course_suggestions
  has_many :providers, :through => :provider_course_suggestions

  validates_presence_of :name, :description
  validates_presence_of :join_providers, :on => :create
  validates_presence_of :provider_ids, :on => :update

  after_create :create_provider_associations

  private

  def create_provider_associations
    return unless join_providers.is_a?(Array)
    join_providers.each do |provider_id|
      self.providers << Provider.find(provider_id)
    end
    save!
  end
end
