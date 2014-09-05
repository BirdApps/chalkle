# Geographical area below country
class Region < ActiveRecord::Base
  attr_accessible :name, :url_name
  attr_accessible :name, :url_name, as: :admin
  default_scope order('name ASC')

  after_create :set_url_name
  def set_url_name
    url_name = name.parameterize
    self.url_name = Region.find_by_url_name(url_name).nil? ? url_name : url_name+self.id.to_s
    save
  end
end