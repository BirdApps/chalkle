class Category < ActiveRecord::Base
  attr_accessible :name

  has_many :group_categories
  has_many :groups, :through => :group_categories
  has_many :lessons
end
