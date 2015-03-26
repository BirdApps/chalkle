class Notify::ProviderTeacherNotification < Notify::Notifier
  
  def initialize(provider_teacher, role = NotificationPreference::CHALKLER)
    @provider_teacher = provider_teacher
    @role = role
  end

  def added_to_provider(inviter)

    ProviderTeacherMailer.added_to_provider(provider_teacher).deliver!
    if provider_teacher.chalkler #check if chalkler is already signed up. 

      message = I18n.t('notify.provider_teacher.added_to_provider', 
        provider_name: @provider_teacher.provider.name    )

      provider_teacher.chalkler.send_notification(
        Notification::CHALKLE, 
        edit_provider_teacher_path(provider_teacher.path_params), 
        message )


    else #invite them if they are not signed up !  

      Chalkler.invite!( {email: provider_teacher.email, name: provider_teacher.name}, inviter )
    
    end

  end


  private
    def provider_teacher
      @provider_teacher
    end
end
