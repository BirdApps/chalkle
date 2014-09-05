require 'spec_helper'

describe CoursesController do
  let(:channel) { FactoryGirl.create(:channel) }

  describe "#show" do
    context "when the course is unpublished" do
      let(:course) { FactoryGirl.create(:course, status: 'On-hold', channel: channel) }
      before { get :show, channel_id: channel.id, id: course.id }

      it "redirects to the chalkler dashboard" do
        expect(response).to redirect_to(root_url)
      end

      it "shows a flash message" do
        expect(flash[:notice]).to eq('This class is no longer available.')
      end
    end

    it "renders the show template" do
      course = FactoryGirl.create(:course, status: 'Published', channel: channel)
      get :show, channel_id: channel.id, id: course.id
      expect(response).to render_template(:show)
    end
  end

  describe "#calculate_cost" do
    it "returns calculated cost value" do
      get :calculate_cost, course: {teacher_cost: '10.00'}
      response.should be_success
      results = JSON.parse(response.body)
      results['cost'].should == '15.0'
    end

    it "will use cost calculator for channel if specified" do
      default_model = CostModel.create(calculator_class_name: 'flat_rate_markup')
      commission_model = CostModel.create(calculator_class_name: 'percentage_commission')
      channel = FactoryGirl.create(:channel, cost_model: commission_model, channel_rate_override: 0.75)

      get :calculate_cost, course: {teacher_cost: '100.0', channel_id: channel.id}
      expect(response).to be_success
      results = JSON.parse(response.body)
      results['cost'].should == '139.0'
    end
  end

  # These are timezone dependent and dont' work on travis
  #describe "#calendar" do
  #let(:this_week) { Week.containing(Time.local(2013,1,2,0,0,0).to_date) }
  #
  #def course_on(start_at)
  #  FactoryGirl.create(:published_course, start_at: start_at, channels: [channel])
  #end
  #  context "weekly courses" do
  #    it "loads courses for current week" do
  #      Timecop.freeze(this_week.tuesday) do
  #        course_on this_week.sunday
  #
  #        get :calendar, channel_id: channel.id
  #        assigns[:week_courses].keys.should == [this_week]
  #      end
  #    end
  #
  #    it "loads courses for next week if it is friday or later" do
  #      Timecop.freeze(this_week.friday) do
  #        course_on this_week.sunday
  #
  #        get :calendar, channel_id: channel.id
  #        assigns[:week_courses].keys.should == [this_week, this_week.next]
  #      end
  #    end
  #
  #    it "loads three weeks if there is no course in the first two weeks" do
  #      Timecop.freeze(this_week.monday) do
  #        course_on (this_week + 2).wednesday
  #
  #        get :calendar, channel_id: channel.id
  #        assigns[:week_courses].keys.length.should == 3
  #        assigns[:week_courses].keys.should == [this_week, this_week.next, this_week + 2]
  #      end
  #    end
  #
  #    it "loads four weeks if there are no courses" do
  #      Timecop.freeze(this_week.monday) do
  #        get :calendar, channel_id: channel.id
  #        assigns[:week_courses].keys.length.should == 4
  #        assigns[:week_courses].keys.should == [this_week, this_week.next, this_week + 2, this_week + 3]
  #      end
  #    end
  #  end
  #end
end
