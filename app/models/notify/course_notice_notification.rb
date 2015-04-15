class Notify::CourseNoticeNotification < Notify::Notifier
  
  def initialize(course_notice, role = NotificationPreference::CHALKLER)
    @course_notice = course_notice
    @role = role
  end
  
  def created
    message = I18n.t('notify.discussion.from_'+role.to_s, from_name: course_notice.chalkler.name, course_name: course_notice.course.name)

    chalklers_to_notify = course_notice.course.followers_except(current_user)

    chalklers_to_notify.each do |chalkler|
      chalkler.send_notification Notification::REMINDER, provider_course_path(course_notice.course.path_params.merge(anchor: "discuss-#{course_notice.id}") ), message, course_notice
    
      permission = if role == :teacher  
        :course_notice_new_from_teacher_to_chalkler 
      else 
        :course_notice_new_from_chalkler_to_chalkler
      end

      DiscussionMailer.delay.send('new_from_'+role.to_s, course_notice, chalkler) if chalkler.email_about? permission

    end

    unless (role == :teacher) || chalklers_to_notify.include?(course_notice.teacher.chalkler)

      if course_notice.teacher.chalkler.present?
        course_notice.teacher.chalkler.send_notification Notification::REMINDER, provider_course_path(course_notice.course.path_params(anchor: "discuss-#{course_notice.id}") ), message, course_notice 
      end

      if course_notice.teacher.chalkler.blank? || course_notice.teacher.chalkler.email_about?(:course_notice_new_from_chalkler_to_teacher)
        DiscussionMailer.delay.send('new_from_'+role.to_s, course_notice, course_notice.teacher.email)
      end

    end

  end


  private
    def course_notice
      @course_notice
    end

end
