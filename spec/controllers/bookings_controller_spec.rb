require "spec_helper"

describe BookingsController do
  describe "#new" do
    context "course status" do
      login_chalkler
      let(:channel) { FactoryGirl.create(:channel) }

      context "free courses" do 
        let(:course) { FactoryGirl.create(:course, status: 'Published', channel: channel, cost: 0, teacher_cost: 0 ) }
        
        it 'creates a booking' do 
          post :create, {
            course_id: course.id, 
            booking_set: {
              bookings: [{
                course_id: course.id, 
                :name => "mr man" , 
                :note_to_teacher => "this is my fav" 
              }]
            }
          }

          expect(response).to redirect_to(channel_course_path(channel.url_name, course.url_name, course.id))
        end
      end

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
