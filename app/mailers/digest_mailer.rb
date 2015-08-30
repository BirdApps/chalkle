# encoding: UTF-8
class DigestMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>' 

  def course_digest(chalkler)
    @chalkler = chalkler
    @digest = CourseDigest::CourseDigest.new chalkler
    @courses = @digest.courses
    if @courses.present?
      mail(to: chalkler.email, subject: @digest.title, name: chalkler.name) do |format| 
        format.text { render layout: 'standard_mailer' }
        format.html { render layout: 'standard_mailer' }
      end
      @digest.sent!
    end
  end

end