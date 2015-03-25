class TheUser

  def initialize current_chalkler
    @chalkler = current_chalkler || Chalkler.new
  end

  def id
    chalkler? ? chalkler.id : -1
  end

  def role
    chalkler.role
  end

  def name
    chalkler.name
  end

  def email
    chalkler.email
  end

  def timezone
    "Auckland"
  end

  def authenticated?
    chalkler.id.present?
  end

  def chalkler?
    chalkler.present? && chalkler.id.present?
  end

  def chalkler
    @chalkler
  end

  def avatar
    chalkler.avatar
  end

  def following
    chalkler.providers
  end

  def providers_adminable
    chalkler.id.present? ? chalkler.providers_adminable : Provider.none
  end

  def providers_teachable
    chalkler.id.present? ? chalkler.providers_teachable : Provider.none
  end

  def subscriptions
    chalkler.present? ? chalkler.subscriptions : Subscription.none
  end

  def provider_admins
    chalkler.id.present? ? chalkler.provider_admins : ProviderAdmin.none
  end

  def provider_teachers
    chalkler.id.present? ? chalkler.provider_teachers : ProviderTeacher.none
  end

  def courses_teaching
    chalkler.id.present? ? chalkler.courses_teaching : Course.none
  end

  def bookings
    chalkler.id.present? ? chalkler.bookings : Booking.none
  end

  def courses
    chalkler.id.present? ? chalkler.confirmed_courses : Course.none
  end

  def providers
    return Provider.all if super?
    providers = []
    providers = providers.concat chalkler.providers_teachable if chalkler?
    providers = providers.concat chalkler.providers_adminable if chalkler?
    providers.uniq
  end

  def courses_adminable
    chalkler.id.present? ? chalkler.courses_adminable : Course.none
  end

  def courses_teaching
    chalkler.id.present? ? chalkler.courses_teaching : Course.none
  end

  def upcoming_teaching
    chalkler.id.present? ? chalkler.upcoming_teaching : Course.none
  end

  def all_teaching
    chalkler.id.present? ? chalkler.all_teaching : Course.none
  end

  def learn_menu_badge_count 
    @learn_menu_badge_count ||= (
      if chalkler?
        chalkler.confirmed_courses.count
      else
        0
      end
    )
  end

  def teach_menu_badge_count
    @teach_menu_badge_count ||= chalkler? ? chalkler.upcoming_teaching.count : 0
  end

  private 
    def method_missing(method, *args, &block)  
      chalkler.send(method, *args, &block)
    end  
end