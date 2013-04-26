class LessonSuggestion < ActiveRecord::Base
  attr_accessible :description, :name, :category_id, :channel_ids, :join_channels
  attr_accessor :join_channels

  belongs_to :chalkler
  belongs_to :category
  has_many :channel_lesson_suggestions
  has_many :channels, :through => :channel_lesson_suggestions

  accepts_nested_attributes_for :channel_lesson_suggestions

  validates :chalkler, :name, :description, :join_channels, :presence => true

  after_create :create_channel_associations

  private

  def create_channel_associations
    join_channels.reject!(&:empty?)
    join_channels.each do |channel_id|
      self.channels << Channel.find(channel_id)
    end
    save!
  end
end
