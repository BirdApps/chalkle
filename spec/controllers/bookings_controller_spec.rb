require "spec_helper"

describe BookingsController do
  describe "#new" do
    context "lesson status" do
      login_chalkler
      let(:channel) { FactoryGirl.create(:channel) }

      context "when the lesson is unpublished" do
        let(:lesson) { FactoryGirl.create(:lesson, status: 'On-hold', channel: channel) }
        before { get :new, channel_id: channel.id, lesson_id: lesson.id }

        it "redirects to the chalkler dashboard" do
          expect(response).to redirect_to(chalklers_root_url)
        end

        it "shows a flash message" do
          expect(flash[:notice]).to eq('This class is no longer available.')
        end
      end

      it "renders the new template" do
        lesson = FactoryGirl.create(:lesson, status: 'Published', channel: channel)
        get :new, channel_id: channel.id, lesson_id: lesson.id
        expect(response).to render_template(:new)
      end
    end
  end
end
