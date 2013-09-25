module ChalkleMeetup
  class LessonImporter
    def import(data, channel)
      lesson = Lesson.find_or_initialize_by_meetup_id data.id
      lesson.status = Lesson::STATUS_1
      lesson.name = lesson.set_name data.name
      lesson.meetup_id = data.id
      lesson.meetup_url = data.event_url
      lesson.description = data.description
      lesson.meetup_data = data.to_json
      lesson.max_attendee = data.rsvp_limit
      lesson.start_at = data.time if (data.status == "upcoming" && data.time.present?)
      lesson.published_at = Time.at(data.created / 1000) if (data.status == "upcoming" && data.created.present?)
      lesson.updated_at = data.updated
      lesson.duration = data.duration / 1000 if data.duration

      if lesson.new_record?
        lesson.created_at = Time.at(data.created / 1000)
      end

      lesson.save
      lesson.set_category data.name
      lesson.channels << channel unless lesson.channels.exists? channel
      lesson
    end

  end
end