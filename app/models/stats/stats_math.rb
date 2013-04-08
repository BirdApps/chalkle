class StatsMath

  attr_reader :values

  def initialize(values)
    @values = values
  end

  def average(elements = values.length)
    output = @values.first(elements)
    mean(output)
  end

  def percent_average(elements = values.length - 1)
    output = percent_change.first(elements)
    mean(output)
  end

  private 
  def mean(input)
    input.compact!
    input.length > 0 ? input.sum / input.length : nil
  end

end
