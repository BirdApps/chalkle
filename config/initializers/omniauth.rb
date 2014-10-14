OmniAuth.config.logger = Rails.logger

environment_keys = Facebook.keys

if environment_keys
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, environment_keys[:app_id], environment_keys[:secret]
    provider :developer if Rails.env.development?
  end

  if Rails.env.development?
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  end
end
