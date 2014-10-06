class TheUser

  def initialize current_chalkler, current_admin_user = nil
    @chalkler = current_chalkler || Chalkler.new
    @admin_user = current_admin_user || AdminUser.new
    @admin_user = AdminUser.find_by_email chalkler.email if @admin_user.id.nil? && @chalkler.id.present?
    @chalkler = Chalkler.find_by_email admin_user.email if @chalkler.id.nil? && @admin_user.id.present?
  end

  def authenticated?
    !!(chalkler || admin_user)
  end

  def admin?
    !admin_user.nil?
  end

  def chalkler?
    !chalkler.nil?
  end

  def role
    admin_user.role if admin_user
  end

  def name
    chalkler.name ? chalkler.name : admin_user.name if authenticated?
  end 

  def email
    chalkler.email ? chalkler.email : admin_user.email if authenticated?
  end

  def chalkler
    @chalkler
  end

  def avatar
    chalkler.avatar
  end

  def admin_user
    @admin_user
  end

  def following
    chalkler.channels
  end

  def super?
    admin_user.present? ? admin_user.super? : false
  end

  def channels_adminable
    chalkler.id.present? ? chalkler.channels_adminable : Channel.none
  end

  def subscriptions
    chalkler.present? ? chalkler.subscriptions : Subscription.none
  end

  def channel_admins
    chalkler.id.present? ? chalkler.channel_admins : ChannelAdmin.none
  end

  def channel_teachers
    chalkler.id.present? ? chalkler.channel_teachers : ChannelTeacher.none
  end

  def courses_teaching
    chalkler.id.present? ? chalkler.courses_teaching : Course.none
  end

  def bookings
    chalkler.id.present? ? chalkler.bookings : Booking.none
  end

  def courses
    chalkler.id.present? ? chalkler.courses : Course.none
  end

  def channels
    return Channel.all if super?
    channels = []
    channels = channels.concat admin_user.channels if admin?
    channels = channels.concat chalkler.channels_teachable if chalkler?
    channels.uniq
  end
end