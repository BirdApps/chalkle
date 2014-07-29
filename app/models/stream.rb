class Stream < ActiveRecord::Base
  attr_accessible :name, :as => :admin

  has_many :courses

  def self.select_options
    all(order: "name").map { |c| [c.name, c.id] }
  end
end
