class NotificationPreference < ActiveRecord::Base
  *BASE = [:chalkler, :chalkler_id]

  *CHALKLER_OPTIONS = [:chalkler_discussion_from_chalkler, :chalkler_discussion_from_teacher]

  *TEACHER_OPTIONS = [:teacher_bookings, :teacher_discussion]

  *PROVIDER_OPTIONS = [:provider_bookings, :provider_discussion]

  attr_accessible *BASE, *CHALKLER_OPTIONS, *TEACHER_OPTIONS, *PROVIDER_OPTIONS

  belongs_to :chalkler

  PROVIDER = :provider
  TEACHER = :teacher
  CHALKLER = :chalkler
  ROLES = [PROVIDER,TEACHER,CHALKLER]

  def email_about?(preference_attr)
    true
    #TODO: check email preferences by analyzing string
  end

end