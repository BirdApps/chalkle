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

      before do
      	@email = BookingMailer.first_reminder_to_pay(chalkler,course).deliver
      end

      pending "should deliver to the right person" do
      	@email.should deliver_to(chalkler.email)
      end

    	pending "should have the right subject" do
    		@email.should have_subject(chalkler.name + " - " + course.name)
    	end

    	pending "should have the right salutation" do
    		@email.should have_body_text(chalkler.name.split[0])
    	end

    	pending "should have the right GST inclusive price" do
    		@email.should have_body_text((course.cost*1.15).to_s)
    	end

    end
  end

    describe "Payment reminder email" do
      
      before do
        teacher = FactoryGirl.create(:chalkler, name: "Britany Spears", email: "britany@spears.com")
        @chalkler = FactoryGirl.create(:chalkler, name: "Michael Jackson", email: "michael@jackson.com")
        channel = FactoryGirl.create(:channel, name: "Music", account: "11-1111-1234567-00", url_name: 'sixdegrees')
        @course = FactoryGirl.create(:course, name: "Chalkle Class 5", start_at: 2.days.from_now, cost: 10, teacher_id: teacher.id, venue: "Town Hall", prerequisites: "White shoes", channel: channel)
        @booking = FactoryGirl.create(:booking, chalkler_id: @chalkler.id, course_id: @course.id, payment_method: "cash", guests: 2)
        @email = BookingMailer.pay_reminder(@chalkler, [@booking]).deliver
      end

      it "should deliver to the right person" do
        @email.should deliver_to("michael@jackson.com")
      end

      it "should have the right salutation" do
        @email.should have_body_text("Hello Michael")
      end

      it "should have the class name" do
        @email.should have_body_text("Chalkle class 5")
      end

      it "should tell chalklers what to bring to the class" do
        @email.should have_body_text("White shoes")
      end

      it "should display the number of guests" do
        @email.should have_body_text("You and 2 guests")
      end

      it "should display the total price" do
        @email.should have_body_text("$30.00")
      end

      it "should display how to pay" do
        @email.should have_body_text("Pay $30.00 cash at Te Takere service desk")
      end

      it "should display how to pay for bank transfer" do
        @booking.update_attributes({:payment_method => "bank"}, :as => :admin)
        email = BookingMailer.pay_reminder(@chalkler, [@booking]).deliver
        email.should have_body_text("Deposit $30.00 into the following account:")
      end

      it "should display how to pay for people who booked using Meetup" do
        @course.update_attributes({:meetup_url =>'http://meetup.com'}, :as => :admin)
        @booking.update_attributes({:payment_method => "meetup"}, :as => :admin)
        @booking.reload
        email = BookingMailer.pay_reminder(@chalkler, [@booking]).deliver
        email.should have_body_text(/#{@course.meetup_url}/)
      end

      it "should should not show guests when there aren't any" do
        @booking.update_attributes({:guests => 0}, :as => :admin)
        email = BookingMailer.pay_reminder(@chalkler, [@booking]).deliver
        email.should_not have_body_text("You and 2 guests")
      end

      it "should should say TBD when venue is absent" do
        @course.update_attributes({:venue => nil}, :as => :admin)
        email = BookingMailer.pay_reminder(@chalkler, [@booking.reload]).deliver
        email.should have_body_text("TBD")
      end
    end

end
