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

    describe "Payment reminder email" do
      
      let(:teacher){FactoryGirl.create(:chalkler, name: "Britany Spears", email: "britany@spears.com")}
      let(:chalkler){FactoryGirl.create(:chalkler, name: "Michael Jackson", email: "michael@jackson.com")}
      let(:channel){FactoryGirl.create(:channel, name: "Music", account: "11-1111-1234567-00", url_name: 'sixdegrees')}
      let(:lesson){FactoryGirl.create(:lesson, start_at: 2.days.from_now, duration: 1.5)}
      let(:course){FactoryGirl.create(:course, name: "Chalkle Class 5", lessons: [lesson], cost: 10, teacher_id: teacher.id, venue: "Town Hall", prerequisites: "White shoes", channel: channel)}
      let(:booking){FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id: course.id, payment_method: "cash", guests: 2)}
      let(:email){BookingMailer.pay_reminder(chalkler, [booking]).deliver}

      it "should deliver to the right person" do
        expect(email.to).to eq ["michael@jackson.com"]
      end

      it "should have the right salutation" do
        expect(email).to have_content("Hello Michael")
      end

      it "should have the class name" do
        expect(email).to have_content("Chalkle class 5")
      end

      it "should tell chalklers what to bring to the class" do
        expect(email).to have_content("White shoes")
      end

      it "should display the number of guests" do
        expect(email).to have_content("You and 2 guests")
      end

      it "should display the total price" do
        expect(email).to have_content("$30.00")
      end

      it "should display how to pay" do
        expect(email).to have_content("Pay $30.00 cash at Te Takere service desk")
      end

      it "should display how to pay for bank transfer" do
        booking.update_attributes({:payment_method => "bank"}, :as => :admin)
        email = BookingMailer.pay_reminder(chalkler, [booking]).deliver
        expect(email).to have_content("Deposit $30.00 into the following account:")
      end

      it "should should not show guests when there aren't any" do
        booking.update_attributes({:guests => 0}, :as => :admin)
        email = BookingMailer.pay_reminder(chalkler, [booking]).deliver
        expect(email).to_not have_content("You and 2 guests")
      end

      it "should should say TBD when venue is absent" do
        course.update_attributes({:venue => nil}, :as => :admin)
        email = BookingMailer.pay_reminder(chalkler, [booking.reload]).deliver
        expect(email).to have_content("TBD")
      end
    end

end
