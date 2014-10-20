# encoding: UTF-8
class ChalklerMailer < ActionMailer::Base
  default from: '"chalkle°" <learn@chalkle.com>'

  def welcome(chalkler)
    @chalkler = chalkler
    mail(to: @chalkler.email, subject: "#{@chalkler.name} welcome to a whole new world of learning!") do |format|
      format.text { render :layout => 'standard_mailer' }
      format.html { render :layout => 'standard_mailer' }
    end
  end

  def digest(chalkler, new_courses, open_courses)
    @chalkler = ChalklerDecorator.decorate(chalkler)
  	@new_courses = CourseDecorator.decorate_collection(new_courses)
  	@open_courses = CourseDecorator.decorate_collection(open_courses)
    subject = "chalkle° - #{@chalkler.email_frequency.titleize} digest for #{Date.current.to_formatted_s(:long)}"
  	mail(to: @chalkler.email, subject: subject) do |format|
      format.text { render :layout => 'standard_mailer' }
      format.html { render :layout => 'standard_mailer' }
    end
  end
end
