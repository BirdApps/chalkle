class CurrencyInput < SimpleForm::Inputs::Base
  def input(wrapper_options="")
    input_html_options[:class] << :'currency-input'
    input_html_options[:class] << :'form-control'
    "<span class='currency-input-symbol'>$</span> #{@builder.text_field(attribute_name, input_html_options)}".html_safe
  end
end