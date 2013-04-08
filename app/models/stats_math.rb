class Stats_math

  attr_reader :values

  def initialize(values)
    @values = values
  end

  def percent_change
    output = []
    (1..(@values.length - 1)).each do |i|
      output[i-1] = (@values[i] > 0) ? (@values[i-1].to_d / @values[i] - 1)*100.0 : nil
    end
    output
  end 

  def subtract(array)
    return if (@values.length != array.length)
    output = []
    (1..(@values.length - 1)).each do |i|
      output[i-1] = (@values[i-1].nil? || array[i-1].nil?) ? nil : (@values[i-1] - array[i-1])
    end
    output
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
