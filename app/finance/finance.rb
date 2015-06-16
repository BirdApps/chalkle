module Finance
  CHALKLE_GST_NUMBER = "109-389-226"

  def self.sales_tax_for(country_code)
    case country_code
      when :nz
        0.15
      else
        0
      end
  end

  def self.reverse_sales_tax_for(country_code)
    case country_code
      when :nz
        3/23.to_f
      else
        0
      end
  end

  def self.apply_sales_tax_to(value, country_code = :nz)
    tax = self.sales_tax_for(country_code)
    value = value+value*tax
  end

  def self.remove_sales_tax_from(value, country_code = :nz)
    negate_tax = self.reverse_sales_tax_for(country_code)
    value = value-value*negate_tax
  end

  def self.payment_methods
    ['Credit or Debit Card']
  end
end