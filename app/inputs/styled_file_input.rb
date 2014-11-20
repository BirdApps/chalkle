class StyledFileInput < SimpleForm::Inputs::Base
  def input
    input_html_options[:type] = :file
    input_html_options[:content] = "Choose file" unless input_html_options[:content].present?
    "<div class='fakefilename'></div>
    <div class='styled-file'>
      #{ @builder.text_field(attribute_name, input_html_options)}
      <div class='btn btn-primary fakebtn'>
        #{ input_html_options[:content] }
      </div>
    </div>
    ".html_safe
  end
end