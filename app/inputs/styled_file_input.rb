class StyledFileInput < SimpleForm::Inputs::Base
  def input
    input_html_options[:type] = :file
    "<div class='fakefilename'></div>
    <div class='styled-file'>
      #{ @builder.text_field(attribute_name, input_html_options)}
      <div class='btn btn-primary fakebtn'>Choose file</div>
    </div>
    ".html_safe
  end
end