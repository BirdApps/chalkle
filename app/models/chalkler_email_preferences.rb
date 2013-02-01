class ChalklerEmailPreferences
  include Informal::Model

  attr_accessor :email, :email_frequency, :email_categories

  def initialize(chalkler)
    @email = chalkler.email
    @email_frequency = chalkler.email_frequency
    @email_categories = chalkler.email_categories
  end
end
