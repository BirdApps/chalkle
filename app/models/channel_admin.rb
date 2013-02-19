class GroupAdmin < ActiveRecord::Base
  validates_uniqueness_of :admin_user_id, :scope => :group_id
  belongs_to :group
  belongs_to :admin_user
end
