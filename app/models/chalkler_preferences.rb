class ChalklerPreferences
  include ActiveAttr::Model

  attr_accessor :chalkler, :email, :email_frequency, :email_categories, :email_streams

  validates :email, allow_blank: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, :message => "Email must be in the correct format"}

  def initialize(chalkler)
    @chalkler         = chalkler
    @email            = @chalkler.email
    @email_frequency  = @chalkler.email_frequency
    @email_categories = @chalkler.email_categories
    @email_streams    = @chalkler.email_streams
  end

  def update_attributes(params)
    @email            = params[:email]
    @email_frequency  = params[:email_frequency]
    @email_categories = parse_categories_params(params[:email_categories])
    @email_streams    = parse_streams_params(params[:email_streams])
    valid? && persist_to_chalkler
  end

  private

  def parse_categories_params(email_categories)
    email_categories = email_categories.to_a.delete_if(&:blank?)
    email_categories.map(&:to_i)
  end

  def parse_streams_params(email_streams)
    email_streams = email_streams.to_a.delete_if(&:blank?)
    email_streams.map(&:to_i)
  end

  def persist_to_chalkler
    @chalkler.email            = @email
    @chalkler.email_frequency  = @email_frequency
    @chalkler.email_categories = @email_categories
    @chalkler.email_streams    = @email_streams
    @chalkler.save
  end
end
