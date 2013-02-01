class ChalklerPreferences
  include ActiveAttr::Model

  attr_accessor :chalkler, :email, :email_frequency, :email_categories

  def initialize(chalkler)
    @chalkler         = chalkler
    @email            = @chalkler.email
    @email_frequency  = @chalkler.email_frequency
    @email_categories = @chalkler.email_categories
  end

  def update_attributes(params)
    @email            = params[:email]
    @email_frequency  = params[:email_frequency]
    @email_categories = params[:email_categories]
    persist_to_chalkler
  end

  private

  def persist_to_chalkler
    @chalkler.email            = @email
    @chalkler.email_frequency  = @email_frequency
    @chalkler.email_categories = @email_categories
    @chalkler.save
  end
end
