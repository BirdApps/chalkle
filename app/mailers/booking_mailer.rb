class BookingMailer < ActionMailer::Base
  default from: "accounts@chalkle.com"

  def first_reminder_to_pay(chalkler,lesson) 
  	#this email is sent both when a new confirmed booking is made, unless it is made less than 3 days from start of class
  	@chalkler = chalkler
  	@lesson = lesson
  	mail(to: chalkler.email, subject: lesson.name)
  end

  def second_reminder_to_pay
  	#this tells them they will be moved to waitlist if they don't pay, sent 3 days before class
  end

  def third_reminder_to_pay
  	#this tells them they will be moved to yes if they pay, sent 2 days before class
  	#DO NOT automate this until push to meetup has been achieved
  end

end
