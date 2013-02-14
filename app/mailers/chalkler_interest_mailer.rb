class ChalklerInterestMailer < ActionMailer::Base
  default from: "learn@chalkle.com"

  def daily_digest(chalkler,new_lessons,closing_lessons) 
  	#take in name of the person to send email to and new lessons in the last 24 hours
  	@chalkler = chalkler
  	@new_lessons = new_lessons
  	@closing_lessons = closing_lessons
  	mail(to: chalkler.email, subject: chalkler.name + " - Here is your daily digest for " + Date.today().to_s)
  end
end
