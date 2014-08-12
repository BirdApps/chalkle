class ClockInput < SimpleForm::Inputs::Base
  def input
    input_html_options[:type] = :hidden
    "<div class='bootstrap-timepicker'>
      #{ @builder.text_field(attribute_name, input_html_options)}
      <input class='form-control time-picker' type='text' readonly='true' name='timepick' />
    </div>
    ".html_safe
  end
end