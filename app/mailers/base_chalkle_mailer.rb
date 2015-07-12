# encoding: UTF-8
class BaseChalkleMailer < ActionMailer::Base
  helper CourseHelper #TODO fix the total weirdness of having the course helper here. Some kind of date lib probably needed

  def mail(args)
    # Fixes SMTP trying to send emails without email addresses
    return if args[:to].nil?
    super
  end


end