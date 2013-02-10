require "spec_helper"

describe BookingMailer do
	include EmailSpec::Helpers
  include EmailSpec::Matchers

  describe "New booking" do

    describe "made on meetup" do
      let(:booking_mailer) { BookingMailer }

      pending "should send a reminder to pay email when a new booking is made on meetup" do
        result = MeetupApiStub::rsvp_response
        lesson = Lesson.create(name: "ABC", meetup_id: 12345678, cost: 10, start_at: Date.tomorrow)
        chalkler = FactoryGirl.create(:chalkler, meetup_id: 12345678) 
        Booking.create_from_meetup_hash result
        BookingMailer.should_receive(:first_reminder_to_pay).with(chalkler, lesson).and_return(booking_mailer)
      end
    end

    describe "reminder email content" do

      let(:lesson) { FactoryGirl.create(:lesson, cost: 10) }
      let(:chalkler) { FactoryGirl.create(:chalkler) }
      let(:booking) { FactoryGirl.create(:booking, guests: 5, cost_override: nil, lesson: lesson, chalkler: chalkler) } 

      before do
      	@email = BookingMailer.first_reminder_to_pay(chalkler,lesson).deliver
      end

      it "should deliver to the right person" do
      	@email.should deliver_to(chalkler.email)
      end

    	it "should have the right subject" do
    		@email.should have_subject(chalkler.name + " - " + lesson.name)
    	end

    	it "should have the right salutation" do
    		@email.should have_body_text(chalkler.name.split[0])
    	end

    	it "should have the right GST inclusive price" do
    		@email.should have_body_text((lesson.cost*1.15).to_s)
    	end

    end
  end
end
