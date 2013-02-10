class Channel < ActiveRecord::Base
  attr_accessible :name

  has_many :lessons

  #TODO: Move into a presenter class like Draper sometime
  #FIXME: Data should be inforced in some convention so lowercase conversion is not required here (probably all lowercase)
  def self.select_options
    all(order: "LOWER(name)").map { |c| [c.name.titleize, c.id] }
  end
end
