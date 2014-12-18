class BookingEvent < EntityEvents::EntityEvent
  def new_target
    id = params[:course_id]
    Course.find id if id
  end

  def create_target
    @actor.bookings.last
  end
end