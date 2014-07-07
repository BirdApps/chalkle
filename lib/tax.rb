module Tax
  def gst_rate_for(tax_code = :nz)
    case tax_code
    when :nz
      0.15
    else
      0
  end
end