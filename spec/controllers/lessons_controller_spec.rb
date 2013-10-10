require 'spec_helper'

describe LessonsController do
  let(:channel) { FactoryGirl.create(:channel) }

  def lesson_on(start_at)
    FactoryGirl.create(:published_lesson, start_at: start_at, channels: [channel])
  end

  describe "#calendar" do
    context "weekly lessons" do
      it "loads lessons for current week" do
        Timecop.freeze(Week.current.tuesday) do
          lesson_on Week.current.sunday

          get :calendar, channel_id: channel.id
          assigns[:week_lessons].keys.should == [Week.current]
        end
      end

      it "loads lessons for next week if it is friday or later" do
        Timecop.freeze(Week.current.friday) do
          lesson_on Week.current.sunday

          get :calendar, channel_id: channel.id
          assigns[:week_lessons].keys.should == [Week.current, Week.current.next]
        end
      end

      it "loads three weeks if there is no lesson in the first two weeks" do
        Timecop.freeze(Week.current.monday) do
          lesson_on (Week.current + 2).wednesday

          get :calendar, channel_id: channel.id
          assigns[:week_lessons].keys.length.should == 3
          assigns[:week_lessons].keys.should == [Week.current, Week.current.next, Week.current + 2]
        end
      end

      it "loads four weeks if there are no lessons" do
        Timecop.freeze(Week.current.monday) do
          get :calendar, channel_id: channel.id
          assigns[:week_lessons].keys.length.should == 4
          assigns[:week_lessons].keys.should == [Week.current, Week.current.next, Week.current + 2, Week.current + 3]
        end
      end
    end
  end
end