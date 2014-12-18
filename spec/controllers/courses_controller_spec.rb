require 'spec_helper'

describe CoursesController do
  let(:channel) { FactoryGirl.create(:channel) }

  describe "#show" do
    context "when the course is unpublished" do
      let(:course) { FactoryGirl.create(:course, status: 'Draft', channel: channel) }
      before { get :show, channel_id: channel.id, id: course.id }

      it "redirects to the chalkler dashboard" do
        expect(response).to redirect_to(new_chalkler_session_path)
      end

      it "shows a flash message" do
        expect(flash[:notice]).to eq('You do not have permission to view that page')
      end
    end

  end

  describe "#create" do 
    pending "creates a course" do 
    end
  end

  describe "#calculate_cost" do
    it "returns calculated cost value" do
      #TODO todo?!
    end
  end
end
