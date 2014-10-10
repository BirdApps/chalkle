# Geographical area below country
class Region < ActiveRecord::Base
  attr_accessible :name, :url_name, :courses
  attr_accessible :name, :url_name, :courses, as: :admin
  default_scope order('name ASC')
  after_create :set_url_name

  has_many :courses
  
  scope :with_classes, includes(:courses).where("COUNT(courses.id) > 0")
  scope :alphabetical, order(:name)

  def self.with_displayable_classes_in_future
    regions = []
    Region.all.each do |region|
      regions << region if region.courses.in_future.displayable.count > 0
    end
    regions
  end

  def set_url_name
    url_name = name.parameterize
    self.url_name = Region.find_by_url_name(url_name).nil? ? url_name : url_name+self.id.to_s
    save
  end

  def hero
    nil
  end

end