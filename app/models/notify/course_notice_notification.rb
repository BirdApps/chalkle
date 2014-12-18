class Notify::CourseNoticeNotification < Notify::Notifier
  
  def initialize(course_notice, role = NotificationPreference::CHALKLER)
    @course_notice = course_notice
    @role = role
  end
  
  def created
    message = I18n.t('notify.discussion.from_'+role.to_s, from_name: course_notice.chalkler.name, course_name: course_notice.course.name)

    chalklers_to_notify = course_notice.course.followers_except(current_user)

    chalklers_to_notify.each do |chalkler|
      chalkler.send_notification Notification::REMINDER, course_path(course_notice.course, anchor: "discuss-#{course_notice.id}" ), message, course_notice

      DiscussionMailer.send('new_from_'+role.to_s, course_notice, chalkler).deliver!
    end

    unless chalklers_to_notify.include? course_notice.teacher.chalkler
      course_notice.teacher.chalkler.send_notification Notification::REMINDER, course_path(course_notice.course, anchor: "discuss-#{course_notice.id}" ), message, course_notice if course_notice.teacher.chalkler.present?

      DiscussionMailer.send('new_from_'+role.to_s, course_notice, course_notice.teacher.email).deliver!
    end

  end


  private
    def course_notice
      @course_notice
    end

end
