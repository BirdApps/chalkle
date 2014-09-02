class NumberPickerInput < SimpleForm::Inputs::Base
  def input
    input_html_options[:class] << :'number-picker-input'
    input_html_options[:class] << :'form-control'
    "<div class='number-picker'>
      #{ @builder.text_field(attribute_name, input_html_options)} 
      <div class='control-wrapper'>
        <div class='fa fa-chevron-up number-picker-up'></div>
        <div class='fa fa-chevron-down number-picker-down'></div>
      </div>
    </div>".html_safe
  end
end