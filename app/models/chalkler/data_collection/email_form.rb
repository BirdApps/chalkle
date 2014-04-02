class Chalkler::DataCollection::EmailForm

  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :customer, Chalkler
  attribute :email, String

  validates_presence_of :email
  validates_format_of :email, with: Chalkler::EMAIL_VALIDATION_REGEX
  validate :email_uniqueness

  def initialize(attributes = {})
    @chalkler = attributes["chalkler"]
    @email    = attributes["email"]
  end

  def save
    return false unless valid?
    chalkler.email = email
    chalkler.save
  end

  def persisted?
    false
  end

private

  attr_reader :chalkler, :email

  def email_uniqueness
    if Chalkler.where("LOWER(email) = LOWER(?)", email).to_a.empty?
      errors.add(:email, "has already been taken")
    end
  end

end
