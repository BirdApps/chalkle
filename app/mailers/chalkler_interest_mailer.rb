class ChalklerInterestMailer < ActionMailer::Base
  default from: "learn@chalkle.com"

  def digest(chalkler,new_lessons,still_open_lessons,frequency) 
  	#lesson arguments to this method must be ActiveRecord::Relation
  	@chalkler = chalkler
  	@new_lessons = new_lessons
  	@still_open_lessons = still_open_lessons
  	@frequency = frequency
  	mail(to: chalkler.email, subject: chalkler.name + " - Here is your " + @frequency.to_s + " digest for " + Date.today().to_s)
  end

end
