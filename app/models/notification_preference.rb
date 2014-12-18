class NotificationPreference < ActiveRecord::Base
  *BASE = [:chalkler, :chalkler_id]


  CHALKLER_OPTIONS = [:booking_cancelled_to_chalkler,:booking_completed,:booking_confirmation_to_chalkler,:booking_reminder,:course_notice_new_from_chalkler_to_chalkler,:course_notice_new_from_teacher_to_chalkler
  ]

  TEACHER_OPTIONS = [ :booking_cancelled_to_teacher,:booking_confirmation_to_teacher,:course_cancelled_to_teacher,:course_notice_new_from_chalkler_to_teacher
  ]


  PROVIDER_OPTIONS = []

  *ALL_NOTIFICATIONS = CHALKLER_OPTIONS + TEACHER_OPTIONS + PROVIDER_OPTIONS

  attr_accessible *BASE, *ALL_NOTIFICATIONS

  belongs_to :chalkler

  PROVIDER = :provider
  TEACHER = :teacher
  CHALKLER = :chalkler
  ROLES = [PROVIDER,TEACHER,CHALKLER]

  before_validation :reset_to_default, unless: -> (not_pref){ not_pref.preferences }

  validates_presence_of :preferences

  serialize :preferences


  def reset_to_default
    self.preferences = Hash[ ALL_NOTIFICATIONS.collect{|n| [n, true]} ]
  end

  ALL_NOTIFICATIONS.each do |notification|
    reset_to_default unless preferences
    define_method(notification) do
      preferences.keys.include?(notification) ? preferences[notification] : true
    end
  end

end