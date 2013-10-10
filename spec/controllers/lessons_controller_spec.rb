require 'spec_helper'

describe LessonsController do
  let(:channel) { FactoryGirl.create(:channel) }

  describe "#calendar" do
    context "weekly lessons" do
      it "loads lessons for current week" do
        Timecop.freeze(Week.current.tuesday) do
          get :calendar, channel_id: channel.id
          assigns[:week_lessons].keys.should == [Week.current]
        end
      end

      it "loads lessons for next week if it is friday or later" do
        Timecop.freeze(Week.current.friday) do
          get :calendar, channel_id: channel.id
          assigns[:week_lessons].keys.should == [Week.current, Week.current.next]
        end
      end
    end
  end
end