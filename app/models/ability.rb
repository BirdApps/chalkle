class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    case user.role
    when "super"
      can :manage, AdminUser
      can :manage, Channel
      can [:read, :create, :update, :send_reset_password_mail, :destroy], Chalkler
      can [:read, :create, :update, :hide, :unhide], [Booking, Payment]
      can [:record_cash_payment], Booking
      can [:reconcile, :do_reconcile, :download_from_xero, :unreconcile], Payment
      can :manage, Course
      can [:read, :create, :update], CourseImage
      can :manage, Category
      can :manage, CourseSuggestion
      can :manage, EventLog
      can :manage, Region
      can :manage, PartnerInquiry

    when "channel admin"
      can :read, Channel, :id => user.channel_ids
      can :create, Chalkler
      # TODO: Do this with a single database join
      can [:read, :update, :send_reset_password_mail], Chalkler, :id => user.chalkler_ids
      can :manage, CourseSuggestion
      # TODO: Do this with a single database join
      can [:read, :update, :meetup_template, :copy_course, :hide, :unhide], Course, :id => user.course_ids
      can :create, Course
      can :create, Booking
      # TODO: Do this with a single database join
      can [:record_cash_payment, :read, :update], Booking, :id => user.booking_ids
      can [:read, :create, :update], CourseImage
      cannot [:read, :update, :destroy], [Payment, Category, AdminUser]
      cannot [:update, :destroy], [AdminUser, Channel]
      cannot :destroy, CourseImage
      cannot :manage, PartnerInquiry
    end
  end
end
