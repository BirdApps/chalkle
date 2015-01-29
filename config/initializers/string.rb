class String
  def to_html
    RDiscount.new(ERB::Util::h(self)).to_html.html_safe
  end
end