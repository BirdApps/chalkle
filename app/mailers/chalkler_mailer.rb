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

  def digest(chalkler, new_lessons, open_lessons)
    @chalkler = ChalklerDecorator.decorate(chalkler)
  	@new_lessons = LessonDecorator.decorate_collection(new_lessons)
  	@open_lessons = LessonDecorator.decorate_collection(open_lessons)
    subject = "chalkle° - #{@chalkler.email_frequency.titleize} digest for #{Date.today.to_formatted_s(:long)}"
  	mail(to: @chalkler.email, subject: subject) do |format|
      format.text
      format.html { render :layout => 'standard_mailer' }
    end
  end
end
