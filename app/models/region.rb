# Geographical area below country
class Region < ActiveRecord::Base
  attr_accessible :name, :url_name
  attr_accessible :name, :url_name, as: :admin
  default_scope order('name ASC')
end