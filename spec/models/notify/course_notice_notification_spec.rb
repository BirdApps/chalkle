require 'spec_helper'

describe Notify::CourseNoticeNotification  do
  let(:course_notice) { FactoryGirl.create(:course_notice) }
  let(:stake_holder_count ) { course_notice.course.followers.count + 1 }

  describe ".created" do
    
    it "notifies everyone" do
      expect { Notify.for(course_notice).created }.to change { Notification.scoped.count }.by( stake_holder_count )
    end


    it "emails everyone" do
      expect { Notify.for(course_notice).created }.to change { ActionMailer::Base.deliveries.count }.by( stake_holder_count )
    end

  end
end