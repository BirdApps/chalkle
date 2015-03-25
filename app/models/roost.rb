class Roost
  include HTTParty
  attr_accessor :parameters

  def initialize(initial_chalkler, message, path)
    aliases = [ "#{Rails.env}_#{initial_chalkler.id}" ]
    @parameters = { alert: message, url: url_from_path(path), aliases: aliases }
  end

  def deliver
    begin 
      result = HTTParty.post("https://go.goroost.com/api/push", 
        body: parameters.to_json, 
        headers: { 'Content-Type' => 'application/json' }, 
        basic_auth: keys
      )
      result = JSON.parse(result.response.body)
      if result['success']
        Rails.logger.info "DESKTOP NOTIFICATION: Desktop notification sent to #{parameters[:aliases].to_s}"
      else
        raise ApiError.new(parameters, result) unless result['success']
      end
    rescue ApiError => e
      Airbrake.notify_or_ignore(e, parameters: e.params, error_class: e)
    end
  end

  private

  # we get the path from notifications, but need to send the full URL to the API
  def url_from_path(path)
    unless path =~ /http:\/\//
      "http://" + [ActionMailer::Base.default_url_options[:host], path.split('/').map{|p|p.delete '/'}.reject(&:empty?) ].join("/")
    else
      path
    end
  end


  def keys 
    #username and passsword are the config and secret keys from Roost.com
    {  username: "e7a09481b0d145b784c6b9dd5dd97cb0",
       password: "bdc1164b79c94ca4afc2c443d91afb50" }
  end

  class ApiError < StandardError
    attr_accessor :params, :return_value
    def initialize(params, return_value)
      @params = params
      @return_value = return_value
    end

  end
end

