# encoding: UTF-8
class ChalklerMailer < ActionMailer::Base
  default from: "noreply@chalkle.com"

  def digest(chalkler, new_lessons, open_lessons)
  	@chalkler = chalkler
  	@new_lessons = new_lessons
  	@open_lessons = open_lessons
  	mail(to: chalkler.email,
         subject: "chalkle° - #{chalkler.email_frequency.titleize} class digest for #{Date.today.to_formatted_s(:long)}") do |format|
           format.html { render :layout => 'standard_mailer' }
           format.text
         end
  end
end
