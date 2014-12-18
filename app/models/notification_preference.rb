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
    update_attributes :preferences => Hash[ ALL_NOTIFICATIONS.collect{|n| [n, true]} ]
  end

  ALL_NOTIFICATIONS.each do |notification|

    define_method(notification) do
      reset_to_default if preferences.empty?
      preferences.keys.include?(notification) ? preferences[notification] : true
    end
  
  end

end