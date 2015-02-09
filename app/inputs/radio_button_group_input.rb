class RadioButtonGroupInput < SimpleForm::Inputs::Base
  def input(default_value="")
    default_value = input_html_options[:options].first if input_html_options[:options].present? && default_value == ""
    output = "<div class='btn-group' data-toggle='buttons'>".html_safe
    options = input_html_options[:options]
    input_html_options.delete :options
    options.each do |option|
      output += "<label class='btn btn-info #{ 'active' if option == default_value }'>
        #{ @builder.radio_button(attribute_name, option , input_html_options)} #{option}
      </label>".html_safe
    end
    output += "</div>".html_safe
  end
end