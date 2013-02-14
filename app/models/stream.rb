class Stream < ActiveRecord::Base
  attr_accessible :name

  has_many :lessons

  def self.select_options
    all(order: "name").map { |c| [c.name, c.id] }
  end
end
