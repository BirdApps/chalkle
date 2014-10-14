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
      #TODO todo?!
    end
  end
end
