class Notify::CourseNoticeNotification < Notify::Notifier
  
  include Rails.application.routes.url_helpers

  def initialize(course_notice, role = NotificationPreference::CHALKLER)
    @course_notice = course_notice
    @role = role
  end
  
  def created
    message = I18n.t('notify.discussion.from_'+role.to_s, from_name: course_notice.chalkler.name, course_name: course_notice.course.name)

    chalklers_to_notify = course_notice.course.followers_except(current_user).to_a

    if course_notice.teacher.chalkler.present? && course_notice.teacher.chalkler != current_user
      chalklers_to_notify.push(course_notice.course.teacher.chalkler) 
    end

    chalklers_to_notify.uniq.each do |chalkler|
      chalkler.send_notification Notification::REMINDER, course_path(course_notice.course, anchor: "discuss-#{course_notice.id}" ), message, course_notice

      DiscussionMailer.send('new_from_'+role.to_s, course_notice, chalkler).deliver!
    end

  end


  private
    def course_notice
      @course_notice
    end

end
