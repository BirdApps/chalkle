class StatsMath < Array

  def select_parameter(parameter)
    self.map { |i| eval("i." + parameter)}
  end

  def average(parameter)
  	mean( select_parameter(parameter) )
  end

  private 
  def mean(input)
    input.compact!
    input.length > 0 ? input.sum / input.length : nil
  end

end
