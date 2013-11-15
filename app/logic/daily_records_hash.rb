class DailyRecordsHash
  def initialize(records = nil)
    @contents = {}
    add_records(records) if records
  end

  def each_day(&block)
    @contents.each &block
  end

  def add_records records
    records.each do |record|
      date = record.date
      unless date
        raise ArgumentError "Date records hash cannot hash a record that returns nil from it's :date accessor"
      end
      @contents[date] ||= []
      @contents[date] << record
    end
    self
  end

  def empty?
    @contents.empty?
  end

  def [](date)
    @contents[date]
  end
end