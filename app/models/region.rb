# Geographical area below country
class Region < ActiveRecord::Base
  attr_accessible :name, :url_name, :courses
  attr_accessible :name, :url_name, :courses, as: :admin
  default_scope order('name ASC')
  after_create :set_url_name

  has_many :courses
  scope :with_classes, where( courses: nil)



  def set_url_name
    url_name = name.parameterize
    self.url_name = Region.find_by_url_name(url_name).nil? ? url_name : url_name+self.id.to_s
    save
  end

  def hero
    '/assets/partners/index-hero.jpg'
  end
end