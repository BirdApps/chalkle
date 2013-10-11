require 'spec_helper'

describe LessonsController do
  let(:channel)   { FactoryGirl.create(:channel) }
  let(:this_week) { Week.containing(Date.new(2013,1,1)) }

  def lesson_on(start_at)
    FactoryGirl.create(:published_lesson, start_at: start_at, channels: [channel])
  end

  describe "#calendar" do
    context "weekly lessons" do
      it "loads lessons for current week" do
        Timecop.freeze(this_week.tuesday) do
          lesson_on this_week.sunday

          get :calendar, channel_id: channel.id
          assigns[:week_lessons].keys.should == [this_week]
        end
      end

      it "loads lessons for next week if it is friday or later" do
        Timecop.freeze(this_week.friday) do
          lesson_on this_week.sunday

          get :calendar, channel_id: channel.id
          assigns[:week_lessons].keys.should == [this_week, this_week.next]
        end
      end

      it "loads three weeks if there is no lesson in the first two weeks" do
        Timecop.freeze(this_week.monday) do
          lesson_on (this_week + 2).wednesday

          get :calendar, channel_id: channel.id
          assigns[:week_lessons].keys.length.should == 3
          assigns[:week_lessons].keys.should == [this_week, this_week.next, this_week + 2]
        end
      end

      it "loads four weeks if there are no lessons" do
        Timecop.freeze(this_week.monday) do
          get :calendar, channel_id: channel.id
          assigns[:week_lessons].keys.length.should == 4
          assigns[:week_lessons].keys.should == [this_week, this_week.next, this_week + 2, this_week + 3]
        end
      end
    end
  end
end