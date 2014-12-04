class String
  def to_html
    RDiscount.new(self).to_html.html_safe
  end
end