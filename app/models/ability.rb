class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    case user.role
      when "super"
        can :manage, :all
      end
  end
end
