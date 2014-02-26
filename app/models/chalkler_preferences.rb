class ChalklerPreferences
  include ActiveAttr::Model

  attr_accessor :chalkler, :email, :email_frequency, :email_categories, :email_regions

  validates :email, allow_blank: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, :message => "Email must be in the correct format"}

  def initialize(chalkler)
    @chalkler         = chalkler
    @email            = @chalkler.email
    @email_frequency  = @chalkler.email_frequency
    @email_categories = @chalkler.email_categories
    @email_regions    = @chalkler.email_region_ids
  end

  def update_attributes(params)
    @email            = params[:email]
    @email_frequency  = params[:email_frequency]
    @email_categories = parse_categories_params(params[:email_categories])
    @email_regions    = parse_region_params(params[:email_regions])
    valid? && persist_to_chalkler
  end

  def has_email_category?(category_id)
    @email_categories.nil? || @email_categories.include?(category_id)
  end

  private

    def parse_categories_params(categories)
      parse_models_ids_or_nil categories, Category.all
    end

    def parse_region_params(regions)
      parse_models_ids_or_nil regions, Region.all
    end

    def parse_models_ids_or_nil(model_ids, possible_models)
      models = parse_model_ids(model_ids)
      (possible_models.map(&:id) - models).empty? ? nil : models
    end

    def parse_model_ids(model_ids)
      model_ids.to_a.delete_if(&:blank?).map(&:to_i)
    end

    def persist_to_chalkler
      @chalkler.email            = @email
      @chalkler.email_frequency  = @email_frequency
      @chalkler.email_categories = @email_categories
      @chalkler.email_region_ids = @email_regions
      @chalkler.save
    end
end
