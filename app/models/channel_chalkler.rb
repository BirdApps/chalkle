class GroupChalkler < ActiveRecord::Base
  validates_uniqueness_of :chalkler_id, :scope => :group_id
  belongs_to :group
  belongs_to :chalkler
end
