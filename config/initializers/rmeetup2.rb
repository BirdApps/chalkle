RMeetup2::Base.authentication_method = :api_key
RMeetup2::Base.api_key = '7e4a52464f704b4e1ea2a43166b1410'

RMeetup2::Request.module_eval do
  DOMAIN = "api.meetup.com"

  def execute
    response = Nestful.send(@method, "https://#{DOMAIN}/#{@model}.#{@params[:format]}", :params => @params, :headers => {"Accept-Charset" => "utf-8"})
    RMeetup2::Response.new(response, @params[:format])
  end
end
