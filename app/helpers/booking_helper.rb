module BookingHelper

	def email_subject(chalkler_name,lesson_name)
      URI.escape(chalkler_name) + " - " + URI.escape(lesson_name.gsub(/&/,"and"))
	end

	def email_ending
    URI.escape("

Thank you for supporting chalkle and we look forward to seeing you soon!
chalkle")
  	end

    def payment_detail_bank(reference, price, event_url)
    URI.escape("
Account number: 38-9012-0815531-00
Name: Chalkle Limited
Reference number: ") + reference.to_s + URI.escape(" - Your name
Payment Amount: $") + price.round(2).to_s + URI.escape(" per person incl. GST.") + URI.escape("
") + event_url.to_s
  	end

  	def email_preamble(name, reference, price, event_url)
    URI.escape("
Thank you for signing up to the upcoming chalkle class, ") + URI.escape(name.gsub(/&/,"and")) + URI.escape(". This is a reminder that payment for the class should be made prior to the class. If possible, please make payment via bank transfer or cash deposit at any Kiwibank branch using these details:
") + payment_detail_bank(reference, price, event_url)
  	end

  def send_first_email(name, reference, price, event_url)
    # if first_email_condition
    #   BookingMailer.first_reminder_to_pay(self.chalkler, self.lesson).deliver
    # end
    email_preamble(name, reference, price, event_url) + email_ending
  end

  def send_second_email(name, reference, price, event_url)
    # if second_email_condition
    #   BookingMailer.second_reminder_to_pay(self.chalkler, self.lesson).deliver
    # end
  email_preamble(name, reference, price, event_url) + URI.escape("

If we do not receive your payment within the next 24 hours, your RSVP status will be moved to waitlist to allow other chalklers to attend this class.") + email_ending
  end

  def send_third_email(name, reference, price, event_url)
  email_preamble(name, reference, price, event_url) + URI.escape("

Your RSVP status will be moved to yes when we have received your payment.") + email_ending
  end

  def send_reminder_after_class(name, reference, price, event_url)
    # if reminder_after_class_condition
    #   BookingMailer.reminder_after_class(self.chalkler, self.lesson).deliver
    # end
    URI.escape("
We hope you have enjoyed your recent chalkle class, ") + URI.escape(name.gsub(/&/,"and"))  + URI.escape(".

We have been reconciling our payments and have not found your payment for this class in our records. It may be that your name did not match your payment, and in this case we are very sorry for the email, or that you paid cash on the day and your name was not recorded. If this is the case could you please let us know by replying to this email.

If you have not made a payment for this class, you can do so by bank transfer or cash deposit at any Kiwibank branch using the following details:
  ") + payment_detail_bank(reference, price, event_url) + URI.escape("

Please note, in accordance with chalkle policy payment is required for all who RSVP'd yes on the day of the class even if you choose to not show up.") + email_ending
  end

  def send_no_show_email(name)
    URI.escape("
You have been given a no-show on your chalkle attendance record because you did not show up for the class ") + URI.escape(name.gsub(/&/,"and")) + URI.escape(", which you had RSVP'd for.

Showing up to a class you have committed to is very important because:

1. Chalkle classes are very popular and when you don't show up you have taken up a spot someone else could have enjoyed, and

2. Our teachers have dedicated a lot of time and effort in planning this class for you. When you don't show up it shows a lack of respect for the teacher's time

We recognise that from time to time there will be unavoidable situations which will result in a no-show. For this reason we allow each member 3 no-shows every six months. If you exceed the limited number of no-shows within 6 months, your chalkle membership will be suspended. After another six month period you may request to rejoin.") + self.email_ending
  end

  def reminder_email_content(choice, class_name, reference, price, event_url)
    if choice == 1
      return send_first_email(class_name, reference, price, event_url)
    elsif choice == 2
      return send_second_email(class_name, reference, price, event_url)
    elsif choice == 3
      return send_third_email(class_name, reference, price, event_url)
    elsif choice == 4
      return send_reminder_after_class(class_name, reference, price, event_url)
    elsif choice == "no-show"
      return send_no_show_email(class_name)
  	end
  end

end