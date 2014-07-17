# encoding: UTF-8
class BookingMailer < ActionMailer::Base
  default from: '"chalkle°" <learn@chalkle.com>' 

  def first_reminder_to_pay(chalkler,course)
  	#this email is sent both when a new confirmed booking is made, unless it is made less than 3 days from start of class
  	@chalkler = chalkler
  	@course = course
    @cost = Finance::Tax::NzGst.new.apply_to course.cost
  	mail(to: chalkler.email, subject: chalkler.name + " - " + course.name)
  #  binding.pry 
  end

  def pay_reminder(chalkler,bookings)
    #this email is sent 5 days before the class as a reminder to anyone who hasn't paid and again at 3 days ahead of the class
    @bookings = BookingDecorator.decorate_collection(bookings)
    @chalkler = ChalklerDecorator.decorate(chalkler)
    mail(to: @chalkler.email, subject: @chalkler.name + " - " + "your upcoming 'chalkle°' classes") do |format|
      format.text
      format.html { render :layout => 'standard_mailer' }
    end
  end

  def reminder_after_class(chalkler,course)
    #this chase up payments after the class for no-shows or no-cash
    @chalkler = chalkler
    @course = course
    mail(to: chalkler.email, subject: chalkler.name + " - " + course.name)
  end
end
