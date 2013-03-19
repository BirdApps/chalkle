# You can read about this gist at: http://wealsodocookies.com/posts/how-to-test-facebook-login-using-devise-omniauth-rspec-and-capybara
# which is for twitter. Below is for facebook

def set_omniauth(opts = {})
  default = {:provider => :meetup,
             :uuid     => "1234",
             :meetup => {
                 :email => "ned@hotmail.com",
                 :gender => "Female",
                 :name => "foo",
             }
  }

  credentials = default.merge(opts)
  provider = credentials[:provider]
  user_hash = credentials[provider]

  OmniAuth.config.test_mode = true

  OmniAuth.config.mock_auth[provider] = {
    'uid' => credentials[:uuid],
    'provider' => 'meetup',
    "extra" => {
    "user_hash" => {
      "email" => user_hash[:email],
      "name" => user_hash[:name],
      "gender" => user_hash[:gender]
      }
    }
  }
end

def set_invalid_omniauth(opts = {})

  credentials = { :provider => :facebook,
                  :invalid  => :invalid_crendentials
                 }.merge(opts)

  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[credentials[:provider]] = credentials[:invalid]

end
