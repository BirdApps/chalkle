require 'spec_helper'

describe Notify::CourseNotification  do

  let(:course) { FactoryGirl.create(:course) }

  describe ".cancelled" do
    
    it "notifies teacher" do
      course.teacher.chalkler = FactoryGirl.create :teacher_chalkler
      expect { Notify.for(course).cancelled }.to change { course.teacher.notifications.count }.by(1)
    end

    it "emails teacher" do
      course.teacher.chalkler = FactoryGirl.create :teacher_chalkler
      expect { Notify.for(course).cancelled }.to change { ActionMailer::Base.deliveries.select{ |mail| mail.to.include? course.teacher.email }.count }.by(1)
    end

  end

end