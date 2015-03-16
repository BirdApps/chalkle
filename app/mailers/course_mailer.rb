# encoding: UTF-8
class CourseMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>'

  def cancelled_to_teacher(course)
    @course = course
    @teacher = course.teacher
    @mail_header_color = @course.provider.header_color(:hex)
    mail(to: @teacher.email, subject: I18n.t("email.course.cancelled.to_teacher.subject", course_name: @course.name) ) do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

end
