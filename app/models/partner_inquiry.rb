class PartnerInquiry < ActiveRecord::Base
  attr_accessible :name, :organisation, :location, :contact_details, :comment, :visible

  validates_presence_of :name
  validates_presence_of :contact_details

  scope :visible, where(visible: true)
  scope :hidden, where(visible: false)

end
