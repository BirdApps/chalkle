class CourseStatusDraftNowPreview < ActiveRecord::Migration
  def up
    Course.where(status: 'Draft').update_all(status: 'Preview')
  end

  def down
    Course.where(status: 'Preview').update_all(status: 'Draft')
  end
end
