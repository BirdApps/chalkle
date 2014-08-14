class CurrencyInput < SimpleForm::Inputs::Base
  def input(wrapper_options="")
    if input_html_options[:class].class == String
      input_html_options[:class] += "currency-input form-control" 
    else
      input_html_options[:class] = "currency-input form-control"
    end
    "<span class='currency-input-symbol'>$</span> #{@builder.text_field(attribute_name, input_html_options)}".html_safe
  end
end