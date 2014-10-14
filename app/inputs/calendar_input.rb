class CalendarInput < SimpleForm::Inputs::Base
  def input(default_value="")
    input_html_options[:type] = :hidden
    "<div class='date-picker'>
    </div>
    #{ @builder.text_field(attribute_name, input_html_options) }
    ".html_safe
  end
end