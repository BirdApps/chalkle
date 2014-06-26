# Geographical area below country
class Region < ActiveRecord::Base
  attr_accessible :name
  attr_accessible :name, :url_name, as: :admin
end