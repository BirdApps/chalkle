OmniAuth.config.logger = Rails.logger

keys = {
  development: {
    app_id: '1452930364928440',
    secret: '3891f4047b33ef676caf0720d25c114b'
  },
  staging: {
    app_id: '642856212444818',
    secret: 'e48ae83905c25a08cde69fcaca93e158'
  }
}

environment_keys = keys[Rails.env.to_sym]

if environment_keys
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, environment_keys[:app_id], environment_keys[:secret]
  end

  if Rails.env.development?
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  end
end