class Chalkler::DataCollection::EmailForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :chalkler, :email

  validates_presence_of :email
  validates_format_of :email, with: Chalkler::EMAIL_VALIDATION_REGEX
  validate :email_uniqueness

  def initialize(attributes = {})
    @chalkler = attributes["chalkler"]
    @email    = attributes["email"]
  end

  def save
    return false unless valid?
    chalkler.update_attributes(email: email) if chalkler.email.blank?
  end

  def persisted?
    false
  end

private

  def email_uniqueness
    if find_chalker_by_email(email)
      errors.add(:email, "has already been taken")
    end
  end

  def find_chalker_by_email(email)
    Chalkler.where("LOWER(email) = LOWER(?)", email).first
  end

end
