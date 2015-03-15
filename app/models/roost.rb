class Roost
  include HTTParty
  attr_accessor :parameters

  def initialize(initial_chalkler, message, url)
    @parameters = { alert: message, url: url, aliases: ["#{Rails.env}_#{initial_chalkler.id}"] }
  end

  def deliver
    result = HTTParty.post("https://go.goroost.com/api/push", 
      body: parameters.to_json, 
      headers: { 'Content-Type' => 'application/json' }, 
      basic_auth: keys
    )
    result
  end

  private
  
  def keys 
    #username and passsword are the config and secret keys from Roost.com
    {  username: "e7a09481b0d145b784c6b9dd5dd97cb0",
       password: "bdc1164b79c94ca4afc2c443d91afb50" }
  end

end