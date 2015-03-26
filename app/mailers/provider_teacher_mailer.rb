# encoding: UTF-8
class ProviderTeacherMailer < BaseChalkleMailer

  default from: '"chalkle°" <learn@chalkle.com>'

  def added_to_provider(provider_teacher)
    @provider_teacher = provider_teacher
    @chalkler = provider_teacher.chalkler
    mail(to: provider_teacher.email, subject: "Chalkle: #{provider_teacher.provider.name} has added you as a teacher") do |format| 
      format.html { render layout: 'standard_mailer' }
    end
  end

end
