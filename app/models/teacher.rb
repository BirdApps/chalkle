class Teacher < ActiveRecord::Base
  attr_accessible :name, :qualification

  has_many :lessons
end
