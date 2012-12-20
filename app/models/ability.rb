class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    case user.role
    when "super"
      can :manage, AdminUser
      can :manage, Group

      can :read, Chalkler
      can :create, Chalkler
      can :update, Chalkler

      can :read, Booking
      can :create, Booking
      can :update, Booking

      can :read, Lesson
      can :update, Lesson

      can :read, Payment
      can :create, Payment
      can :update, Payment

      can :manage, Category

    when "group admin"
      can :read, Chalkler, :id => user.chalkler_ids
      can :update, Chalkler, :id => user.chalkler_ids
      can :create, Chalkler

      can :read, Booking, :id => user.booking_ids
      can :update, Booking, :id => user.booking_ids
      can :create, Booking

      can :read, Lesson, :id => user.lesson_ids
      can :update, Lesson, :id => user.lesson_ids

      can :read, Payment
      can :create, Payment
      can :update, Payment

      can :manage, Category
    end
  end
end
