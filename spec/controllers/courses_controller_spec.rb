require 'spec_helper'

describe CoursesController do
  let(:provider) { FactoryGirl.create(:provider) }

  describe "#show" do
    context "when the course is unpublished" do
      let(:course) { FactoryGirl.create(:course, status: 'Preview', provider: provider) }
      before { get :show, provider_id: provider.id, id: course.id }

      it "redirects to the chalkler dashboard" do
        expect(response).to redirect_to(new_chalkler_session_path)
      end

    end

  end

  # describe "#create" do 
  #   pending "creates a course" do 
  #     false
  #   end
  # end

  describe "#calculate_cost" do
    it "returns calculated cost value" do
      #TODO todo?!
    end
  end
end
