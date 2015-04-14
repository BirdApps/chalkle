class NotificationPreference < ActiveRecord::Base
  *BASE = [:chalkler, :chalkler_id, :preferences]


  CHALKLER_OPTIONS = [:booking_cancelled_to_chalkler,:booking_completed,:booking_confirmation_to_chalkler,:booking_reminder,:course_notice_new_from_chalkler_to_chalkler,:course_notice_new_from_teacher_to_chalkler
  ]

  TEACHER_OPTIONS = [ :booking_cancelled_to_teacher,:booking_confirmation_to_teacher,:course_cancelled_to_teacher,:course_notice_new_from_chalkler_to_teacher
  ]


  PROVIDER_OPTIONS = [ :booking_cancelled_to_provider, :booking_confirmation_to_provider # :course_cancelled_to_provider, :course_notice_new_from_chalkler_to_provider, :provider_inquiry 
  ]

  SUPER_OPTIONS = [:new_partner_inquiry, :archived_partner_inquiry]

  *ALL_NOTIFICATIONS = CHALKLER_OPTIONS + TEACHER_OPTIONS + PROVIDER_OPTIONS + SUPER_OPTIONS

  attr_accessible *BASE, *ALL_NOTIFICATIONS

  belongs_to :chalkler

  PROVIDER = :provider
  TEACHER = :teacher
  CHALKLER = :chalkler
  SUPER = :super
  ROLES = [PROVIDER,TEACHER,CHALKLER, SUPER]

  before_validation :reset_to_default, unless: -> (not_pref){ not_pref.preferences }

  validates_presence_of :preferences

  serialize :preferences


  def reset_to_default
    update_attributes :preferences => Hash[ ALL_NOTIFICATIONS.collect{|n| [n, true]} ]
  end

  # We want to make the preference respond to all the possible notifications. 
  # do this using dynaimic codes and defining a method for each possible notification. 
  # maybe too much clever for the sake of dry, but it means you can just add a value to the options arrays up there and it all just works. 
   
  ALL_NOTIFICATIONS.each do |notification|

    define_method(notification) do
      reset_to_default if preferences.nil?
      preferences.keys.include?(notification) ? preferences[notification] : true
    end
  
  end

end