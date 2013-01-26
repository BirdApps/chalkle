class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    case user.role
    when "super"
      can :manage, AdminUser
      can :manage, Group
      can [:read, :create, :update], Chalkler
      can [:read, :create, :update, :hide, :unhide], [Booking, Payment]
      can [:record_cash_payment], Booking
      can [:reconcile, :do_reconcile, :download_from_xero, :unreconcile], Payment
      can [:read, :update, :hide, :unhide], Lesson
      can :manage, Category

    when "group admin"
      can :read, Chalkler, :id => user.chalkler_ids
      can [:read, :update], Lesson, :id => user.lesson_ids
      can [:record_cash_payment], Booking
      cannot [:read, :update, :destroy], [Payment, Booking, Category, AdminUser, Group]
    end
  end
end
