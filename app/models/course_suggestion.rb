class CourseSuggestion < ActiveRecord::Base
  attr_accessible :description, :name, :category_id, :join_channels
  attr_accessible :description, :name, :category_id, :join_channels, :chalkler_id, :channel_ids, :as => :admin

  attr_accessor :join_channels

  belongs_to :chalkler
  belongs_to :category
  has_many :channel_course_suggestions
  has_many :channels, :through => :channel_course_suggestions

  validates_presence_of :name, :description
  validates_presence_of :join_channels, :on => :create
  validates_presence_of :channel_ids, :on => :update

  after_create :create_channel_associations

  private

  def create_channel_associations
    return unless join_channels.is_a?(Array)
    join_channels.each do |channel_id|
      self.channels << Channel.find(channel_id)
    end
    save!
  end
end
