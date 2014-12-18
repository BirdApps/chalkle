# encoding: UTF-8
class CourseMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>'

  def cancelled_to_teacher(course)
    @course = course
    @chalkler = course.teacher.chalkler
    mail(to: @chalkler, subject: "Contact from user on Chalkler, #{@channel_contact.subject}") do |format| 
      format.text { render layout: 'standard_mailer' }
      format.html { render layout: 'standard_mailer' }
    end
  end

end
