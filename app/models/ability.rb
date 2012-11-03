class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    case user.role
      when "super"
        can :manage, :all
      when "group admin"
        can :manage, Chalkler, :groups => { :id => user.groups }
        can :manage, Category, :groups => { :id => user.groups }
        can :manage, Lesson, :groups => { :id => user.groups }
        can :manage, Booking, :lesson => { :id => user.groups.collect(&:lessons).flatten }
        can :manage, Payment, :booking => { :id => user.groups.collect(&:bookings).flatten }
      end
  end
end
