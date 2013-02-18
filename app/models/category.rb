class Category < ActiveRecord::Base
  attr_accessible :name

  has_many :group_categories
  has_many :groups, :through => :group_categories
  has_many :lesson_categories
  has_many :lessons, :through => :lesson_categories
  has_many :lessons

  validates_presence_of :name

  #TODO: Move into a presenter class like Draper sometime
  #FIXME: Data should be inforced in some convention so lowercase conversion is not required here (probably all lowercase)
  def self.select_options
    all(order: "name").map { |c| [c.name, c.id] }
  end
end
