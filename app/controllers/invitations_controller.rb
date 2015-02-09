class InvitationsController < Devise::InvitationsController

  def after_accept_path_for(resource)
    resource.bookings.any? ? course_path(resource.bookings.last.course) : root_path
  end


end