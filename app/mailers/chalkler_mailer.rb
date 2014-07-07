# encoding: UTF-8
class ChalklerMailer < ActionMailer::Base
  default from: '"chalkle°" <learn@chalkle.com>'

  def welcome(chalkler)
    @chalkler = chalkler
    mail(to: @chalkler.email, subject: "Welcome to chalkle°!") do |format|
      format.text
      format.html { render :layout => 'standard_mailer' }
    end
  end

  def digest(chalkler, new_courses, open_courses)
    @chalkler = ChalklerDecorator.decorate(chalkler)
  	@new_courses = CourseDecorator.decorate_collection(new_courses)
  	@open_courses = CourseDecorator.decorate_collection(open_courses)
    subject = "chalkle° - #{@chalkler.email_frequency.titleize} digest for #{Date.today.to_formatted_s(:long)}"
  	mail(to: @chalkler.email, subject: subject) do |format|
      format.text
      format.html { render :layout => 'standard_mailer' }
    end
  end
end
