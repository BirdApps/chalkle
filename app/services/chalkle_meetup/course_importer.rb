module ChalkleMeetup
  class CourseImporter
    def import(data, channel)
      course = Course.find_or_initialize_by_meetup_id data.id
      course.status = Course::STATUS_1
      course.name = course.set_name data.name
      course.meetup_id = data.id
      course.meetup_url = data.event_url
      course.description = data.description
      course.meetup_data = data.to_json
      course.max_attendee = data.rsvp_limit

      #course.start_at = data.time if (data.status == "upcoming" && data.time.present?)
      

      course.published_at = Time.at(data.created / 1000) if (data.status == "upcoming" && data.created.present?)
      course.updated_at = data.updated
      course.duration = data.duration / 1000 if data.duration

      if course.new_record?
        course.created_at = Time.at(data.created / 1000)
      end

      course.channel = channel
      course.save
      course.set_category data.name
      course
    end

  end
end