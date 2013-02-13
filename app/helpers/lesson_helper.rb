module LessonHelper
	def may_cancel_email(name,min_attendee)
    URI.escape("

Thank you for signing up to the upcoming chalkle class ") + URI.escape(name.gsub(/&/,"and")) + URI.escape(". We are writing to tell you that a minimum number of ") + (min_attendee.present? ? min_attendee : 2).to_s + URI.escape(" people is required for this class to go ahead. 

If it is cancelled, you will receive a notice from Meetup upon cancellation and we will try to schedule the class for another date. 

Your Chalkle Administrator")
  	end
end