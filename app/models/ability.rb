class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    case user.role
    when "super"
      can :manage, AdminUser
      can :manage, Channel
      can [:read, :create, :update, :send_reset_password_mail], Chalkler
      can [:read, :create, :update, :hide, :unhide], [Booking, Payment]
      can [:record_cash_payment], Booking
      can [:reconcile, :do_reconcile, :download_from_xero, :unreconcile], Payment
      can [:read, :update, :hide, :unhide, :lesson_email, :payment_summary_email, :meetup_template, :copy_lesson], Lesson
      can [:read, :create, :update], LessonImage
      can :manage, Category
      can :manage, LessonSuggestion
      can :manage, EventLog

    when "channel admin"
      can :read, Channel, :id => user.channel_ids
      can :create, Chalkler
      can [:read, :update, :send_reset_password_mail], Chalkler, :id => user.subscriber_ids
      can :manage, LessonSuggestion
      can [:read, :update, :meetup_template, :copy_lesson, :hide, :unhide], Lesson, :id => user.lesson_ids
      can :create, Booking
      can [:record_cash_payment, :read, :update], Booking, :id => user.booking_ids
      can [:read, :create, :update], LessonImage
      cannot [:read, :update, :destroy], [Payment, Category, AdminUser]
      cannot [:update, :destroy], [AdminUser, Channel]
      cannot :destroy, LessonImage
    end
  end
end
