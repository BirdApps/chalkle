class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    case user.role
      when "super"
        can :manage, :all
      when "group admin"
        can :manage, Chalkler, :groups => { :id => user.groups }
        can :manage, Lesson, :groups => { :id => user.groups }
        # can :manage, Booking do |booking|
          # booking.lesson.groups.include? user.groups
        # end
        can :manage, Booking, :groups => { :id => user.groups }
        can :manage, Category, :groups => { :id => user.groups }
      end
  end
end
