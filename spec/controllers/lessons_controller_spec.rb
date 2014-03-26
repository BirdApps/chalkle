require 'spec_helper'

describe LessonsController do
  let(:channel) { FactoryGirl.create(:channel) }

  describe "#show" do
    context "when the lesson is unpublished" do
      let(:lesson) { FactoryGirl.create(:lesson, status: 'On-hold', channel: channel) }
      before { get :show, channel_id: channel.id, id: lesson.id }

      it "redirects to the chalkler dashboard" do
        expect(response).to redirect_to(chalklers_root_url)
      end

      it "shows a flash message" do
        expect(flash[:notice]).to eq('This class is no longer available.')
      end
    end

    it "renders the show template" do
      lesson = FactoryGirl.create(:lesson, status: 'Published', channel: channel)
      get :show, channel_id: channel.id, id: lesson.id
      expect(response).to render_template(:show)
    end
  end

  describe "#calculate_cost" do
    it "returns calculated cost value" do
      get :calculate_cost, lesson: {teacher_cost: '10.00'}
      response.should be_success
      results = JSON.parse(response.body)
      results['cost'].should == '15.0'
    end

    it "will use cost calculator for channel if specified" do
      default_model = CostModel.create(calculator_class_name: 'flat_rate_markup')
      commission_model = CostModel.create(calculator_class_name: 'percentage_commission')
      channel = FactoryGirl.create(:channel, cost_model: commission_model, channel_rate_override: 0.75)

      get :calculate_cost, lesson: {teacher_cost: '100.0', channel_id: channel.id}
      response.should be_success
      results = JSON.parse(response.body)
      results['cost'].should == '139.0'
    end
  end

  # These are timezone dependent and dont' work on travis
  #describe "#calendar" do
  #let(:this_week) { Week.containing(Time.local(2013,1,2,0,0,0).to_date) }
  #
  #def lesson_on(start_at)
  #  FactoryGirl.create(:published_lesson, start_at: start_at, channels: [channel])
  #end
  #  context "weekly lessons" do
  #    it "loads lessons for current week" do
  #      Timecop.freeze(this_week.tuesday) do
  #        lesson_on this_week.sunday
  #
  #        get :calendar, channel_id: channel.id
  #        assigns[:week_lessons].keys.should == [this_week]
  #      end
  #    end
  #
  #    it "loads lessons for next week if it is friday or later" do
  #      Timecop.freeze(this_week.friday) do
  #        lesson_on this_week.sunday
  #
  #        get :calendar, channel_id: channel.id
  #        assigns[:week_lessons].keys.should == [this_week, this_week.next]
  #      end
  #    end
  #
  #    it "loads three weeks if there is no lesson in the first two weeks" do
  #      Timecop.freeze(this_week.monday) do
  #        lesson_on (this_week + 2).wednesday
  #
  #        get :calendar, channel_id: channel.id
  #        assigns[:week_lessons].keys.length.should == 3
  #        assigns[:week_lessons].keys.should == [this_week, this_week.next, this_week + 2]
  #      end
  #    end
  #
  #    it "loads four weeks if there are no lessons" do
  #      Timecop.freeze(this_week.monday) do
  #        get :calendar, channel_id: channel.id
  #        assigns[:week_lessons].keys.length.should == 4
  #        assigns[:week_lessons].keys.should == [this_week, this_week.next, this_week + 2, this_week + 3]
  #      end
  #    end
  #  end
  #end
end
