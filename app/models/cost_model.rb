class CostModel < ActiveRecord::Base
  attr_accessible :calculator_class_name

  def self.default
    first
  end

end