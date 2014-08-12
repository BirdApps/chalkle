class CalendarInput < SimpleForm::Inputs::Base
  def input(default_value="")
   "<div class='date-picker'>
   </div>
    #{ @builder.text_field(attribute_name, { type: :hidden })} 
    ".html_safe
  end
end