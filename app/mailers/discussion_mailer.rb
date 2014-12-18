class DiscussionMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>' 

  def new_from_teacher(course_notice, chalkler)
    if chalkler.is_a? String
      should_send = true
      to_email = chalkler
    else
      should_send = chalkler.email_about? :course_notice_new_from_teacher_to_chalkler
      to_email = chalkler.email
    end
    
    if should_send
      @notice = course_notice
      mail(to: to_email,  subject: I18n.t("email.discussion.new_from_teacher.subject", from_name: @notice.chalkler.first_name,  course_name: @notice.course.name)) do |format| 
        format.text { render layout: 'standard_mailer' }
        format.html { render layout: 'standard_mailer' }
      end
    end
  end

  def new_from_chalkler(course_notice, chalkler)
    if chalkler.is_a? String
      should_send = true
      to_email = chalkler
    else

      if course_notice.teacher == chalkler 
        should_send = chalkler.email_about? :course_notice_new_from_chalkler_to_teacher
      else
        should_send = chalkler.email_about? :course_notice_new_from_chalkler_to_chalkler
      end

      to_email = chalkler.email
    end

    if should_send
      @notice = course_notice
      mail(to: to_email,  subject: I18n.t("email.discussion.new_from_chalkler.subject", from_name: @notice.chalkler.first_name,  course_name: @notice.course.name)) do |format| 
        format.text { render layout: 'standard_mailer' }
        format.html { render layout: 'standard_mailer' }
      end
    end
  end

end