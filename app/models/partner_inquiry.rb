class PartnerInquiry < ActiveRecord::Base
  attr_accessible :name, :organisation, :location, :contact_details, :comment

  validates_presence_of :name
  validates_presence_of :contact_details

end
