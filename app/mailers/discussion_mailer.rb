class DiscussionMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>' 

  def new_from_teacher(course_notice, chalkler)
    should_send = chalkler.email_about? 'discussion.new_from_teacher'

    if should_send
      @notice = course_notice
      @chalkler = chalkler
      mail(to: @chalkler.email,  subject: I18n.t("email.discussion.new_from_teacher.subject", from_name: @notice.chalkler.first_name,  course_name: @notice.course.name)) do |format| 
        format.text { render layout: 'standard_mailer' }
        format.html { render layout: 'standard_mailer' }
      end
    end
  end

  def new_from_chalkler(course_notice, chalkler)
    if course_notice.teacher == chalkler
      should_send = chalkler.email_about? 'discussion.new_from_chalkler.as_teacher'
    else
      should_send = chalkler.email_about? 'discussion.new_from_chalkler.as_chalkler'
    end

    if should_send
      @notice = course_notice
      @chalkler = chalkler
      mail(to: @chalkler.email,  subject: I18n.t("email.discussion.new_from_chalkler.subject", from_name: @notice.chalkler.first_name,  course_name: @notice.course.name)) do |format| 
        format.text { render layout: 'standard_mailer' }
        format.html { render layout: 'standard_mailer' }
      end
    end
  end

end