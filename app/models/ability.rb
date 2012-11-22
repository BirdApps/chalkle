class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    case user.role
    when "super"
      can :manage, :all
    when "group admin"
      can :manage, Chalkler, :id => user.chalkler_ids
      can :manage, Category, :id => user.category_ids
      can :manage, Booking, :id => user.booking_ids
      can :manage, Payment, :id => user.payment_ids
      can :manage, Lesson, :id => user.lesson_ids
    end
  end
end
