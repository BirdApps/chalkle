class GroupAdmin < ActiveRecord::Base
  belongs_to :group
  belongs_to :admin_user
end
