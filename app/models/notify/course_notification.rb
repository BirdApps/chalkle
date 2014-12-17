class Notify::CourseNotification < Notify::Notifier

  include Rails.application.routes.url_helpers
  
  def initialize(course, role = NotificationPreference::CHALKLER)
    @course = course
    @role = role
  end
  
  private
    def course
      @course
    end

end
