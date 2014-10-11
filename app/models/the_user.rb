class TheUser

  def initialize current_chalkler, current_admin_user = nil
    @chalkler = current_chalkler || Chalkler.new
    @admin_user = current_admin_user || AdminUser.new
    @admin_user = AdminUser.find_by_email chalkler.email if @admin_user.id.nil? && @chalkler.id.present?
    @chalkler = Chalkler.find_by_email admin_user.email if @chalkler.id.nil? && @admin_user.id.present?
  end

  def id
    chalkler? ? chalkler.id : -1
  end

  def authenticated?
    !!(chalkler.id.present? || admin_user.id.present?)
  end

  def admin?
    admin_user.present? && admin_user.id.present?
  end

  def chalkler?
    chalkler.present? && chalkler.id.present?
  end

  def role
    admin_user.role if admin?
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

  def courses_adminable
    chalkler.id.present? ? chalkler.adminable_courses : Course.none
  end

  def learn_menu_badge_count
    @learn_menu_badge_count ||= chalkler ? chalkler.bookings.confirmed.upcoming.count : 0
  end

  def teach_menu_badge_count
    return @teach_menu_badge_count if @teach_menu_badge_count
    return 0 unless chalkler
    (chalkler.channels_adminable.map {|c| c.courses.upcoming(nil, include_unpublished: false) }.flatten + courses_teaching).uniq.count
  end
end