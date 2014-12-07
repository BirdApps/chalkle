require "spec_helper"

describe BookingsController do
  describe "#new" do
    context "course status" do
      login_chalkler
      let(:channel) { FactoryGirl.create(:channel) }

      context "when the course is unpublished" do
        let(:course) { FactoryGirl.create(:course, status: 'Draft', channel: channel) }
        before do 
          get :new, channel_id: channel.id, course_id: course.id
        end

        it "redirects to the chalkler dashboard" do
          expect(response).to redirect_to(root_url)
        end

        it "shows a flash message" do
          expect(flash[:notice]).to eq('This class is no longer available.')
        end
      end

      it "renders the new template" do
        course = FactoryGirl.create(:course, status: 'Published', channel: channel)
        get :new, channel_id: channel.id, course_id: course.id
        expect(response).to render_template(:new)
      end
    end
  end
end
