class NumberPickerInput < SimpleForm::Inputs::Base
  def input
    "<div class='number-picker'>
      #{ @builder.text_field(attribute_name, input_html_options)} 
      <div class='control-wrapper'>
        <div class='fa fa-caret-up num-up'></div>
        <div class='fa fa-caret-down num-down'></div>
      </div>
    </div>".html_safe
  end
end