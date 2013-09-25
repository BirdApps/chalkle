module ChalkleMeetup
  class BookingImporter
    def import(data)
      booking = Booking.find_or_initialize_by_meetup_id data.rsvp_id
      booking.chalkler = Chalkler.find_by_meetup_id data.member["member_id"]
      booking.lesson = Lesson.find_by_meetup_id data.event["id"]
      booking.meetup_id = data.rsvp_id
      booking.payment_method = 'meetup'
      if booking.lesson.class_not_done
        booking.guests = data.guests
        booking.status = data.response
      end
      if booking.new_record?
        booking.created_at = Time.at(data.created / 1000)
      end
      booking.updated_at = Time.at(data.mtime / 1000)
      booking.meetup_data = data.to_json
      booking.save
      booking
    end
  end
end