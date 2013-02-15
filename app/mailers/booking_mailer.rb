class BookingMailer < ActionMailer::Base
  layout 'generic_mailer'
  default from: "accounts@chalkle.com"

  if self.included_modules.include?(AbstractController::Callbacks)
    raise "You've already included AbstractController::Callbacks, remove this line."
  else
    include AbstractController::Callbacks
  end

  before_filter :add_inline_attachments!


  def first_reminder_to_pay(chalkler,lesson) 
  	#this email is sent both when a new confirmed booking is made, unless it is made less than 3 days from start of class
  	@chalkler = chalkler
  	@lesson = lesson
  	mail(to: chalkler.email, subject: chalkler.name + " - " + lesson.name)
  end

  def second_reminder_to_pay(chalkler,lesson)
  	#this tells them they will be moved to waitlist if they don't pay, sent 3 days before class
    @chalkler = chalkler
    @lesson = lesson
    mail(to: chalkler.email, subject: chalkler.name + " - " + lesson.name)
  end

  def third_reminder_to_pay(chalkler,lesson)
  	#this tells them they will be moved to yes if they pay, sent 2 days before class
  	#DO NOT automate this until push to meetup has been achieved
    @chalkler = chalkler
    @lesson = lesson
    mail(to: chalkler.email, subject: chalkler.name + " - " + lesson.name)
  end

  def reminder_after_class(chalkler,lesson)
    #this chase up payments after the class for no-shows or no-cash
    @chalkler = chalkler
    @lesson = lesson
    mail(to: chalkler.email, subject: chalkler.name + " - " + lesson.name)
  end

  def add_inline_attachments!
    attachments.inline["logo.png"] = File.read("#{Rails.root}/public/logo.png")
    puts attachments.inspect
  end
end
