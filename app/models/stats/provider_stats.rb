class ProviderStats
  include ActiveAttr::Model

  attr_accessor :start, :period, :provider

  validates_date :start, :allow_nil => false, :on_or_after => '2012-08-01'
  validates_date :period, :allow_nil => false, :on_after_after => 1.day
  validates :provider, :presence => { :message => "Must have a provider to calculate statistics on"}

  def initialize(start, period, provider)
    @start = start
    @period = period
    @provider = provider
  end

  def financial_stats
    FinancialStats.new(start,period,provider)
  end

  def course_stats
    CourseStats.new(start,period,provider)
  end

  def chalkler_stats
    ChalklerStats.new(start,period,provider)
  end

  private

  def end_time
    start + period
  end

  private

  def percentage_change(initial, final)
    return if initial.nil?
    (initial > 0) ? (final / initial.to_d - 1)*100.0 : nil
  end

end
