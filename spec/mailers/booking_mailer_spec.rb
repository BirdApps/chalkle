require "spec_helper"

describe BookingMailer do
	include EmailSpec::Helpers
  include EmailSpec::Matchers

  describe "New booking" do

    describe "made on meetup" do
      let(:booking_mailer) { BookingMailer }

      pending "should send a reminder to pay email when a new booking is made on meetup" do
        result = MeetupApiStub::rsvp_response
        course = Course.create(name: "ABC", meetup_id: 12345678, cost: 10, start_at: Date.tomorrow)
        chalkler = FactoryGirl.create(:chalkler, meetup_id: 12345678)
        #Booking.create_from_meetup_hash result
        BookingMailer.should_receive(:first_reminder_to_pay).with(chalkler, course).and_return(booking_mailer)
      end
    end

    describe "reminder email content" do

      let(:course) { FactoryGirl.create(:course, cost: 10) }
      let(:chalkler) { FactoryGirl.create(:chalkler) }
      let(:booking) { FactoryGirl.create(:booking, guests: 5, cost_override: nil, course: course, chalkler: chalkler) }
      let(:email) { BookingMailer.first_reminder_to_pay(chalkler,course).deliver }

      it "should deliver to the right person" do
      	expect(email).to deliver_to(chalkler.email)
      end

    	it "should have the right subject" do
        expect(email.subject).to eq (chalkler.name + " - " + course.name)
    	end

    	it "should have the right salutation" do
    		expect(email).to have_content(chalkler.name.split[0])
    	end

    	it "should have the right GST inclusive price" do
    		expect(email).to have_content((course.cost*1.15).to_s)
    	end

    end
  end

end
