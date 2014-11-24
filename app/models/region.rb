# Geographical area below country
class Region < ActiveRecord::Base
  attr_accessible :name, :url_name, :courses
  attr_accessible :name, :url_name, :courses, as: :admin

  default_scope order('name ASC')

  before_validation :check_url_name
  after_create :set_url_name!

  #mount_uploader :hero, ChannelHeroUploader

  has_many :courses
  has_many :interaction, as: :actor 
  has_many :interaction, as: :target
  
  scope :with_classes, includes(:courses).where("COUNT(courses.id) > 0")
  scope :alphabetical, order(:name)

  def set_url_name!
    check_url_name
    save
  end

  def check_url_name
    url_name = self.url_name.nil? ? name.parameterize : self.url_name.parameterize
    existing_regions = Region.where(url_name: url_name)
    valid = existing_regions.blank? || (existing_regions.first.id == self.id && existing_regions.count == 1)
    self.url_name = valid ? url_name : url_name+id.to_s
  end


  def hero
    nil
  end

end