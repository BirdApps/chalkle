class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    case user.role
    when "super"
      can :manage, AdminUser
      can :manage, Group
      can [:read, :create, :update], Chalkler
      can [:read, :create, :update, :set_visible], [Booking, Payment]
      can [:read, :update, :set_visible], Lesson
      can :manage, Category

    when "group admin"
      can [:read, :update], Chalkler, :id => user.chalkler_ids
      can :create, Chalkler
      can [:read, :update, :set_visible], Booking, :id => user.booking_ids
      can :create, Booking
      can [:read, :update, :set_visible], Lesson, :id => user.lesson_ids
      can [:read, :create, :update, :set_visible], Payment
      can :manage, Category
    end
  end
end
