class GroupCategory < ActiveRecord::Base
  validates_uniqueness_of :category_id, :scope => [:group_id]
  belongs_to :group
  belongs_to :category
end
