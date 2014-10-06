class ChangeCourseStatusOnHoldToCancelled < ActiveRecord::Migration
  def up
    Course.where(status: 'On-hold').update_all("status = 'Cancelled'")
  end

  def down
      Course.where(status: 'Cancelled').update_all("status = 'On-hold'")
  end
end
