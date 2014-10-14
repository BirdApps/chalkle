class Facebook
  def self.keys
    facebook_keys = {
      development: {
          app_id: '1452930364928440',
          secret: '3891f4047b33ef676caf0720d25c114b'
        },
        staging: {
          app_id: '642856212444818',
          secret: 'e48ae83905c25a08cde69fcaca93e158'
        },
        production: {
          app_id: '709387515738435',
          secret: 'c97d4ae964a5ce9cb36eea58a6d046a5'
        }
      }
    facebook_keys[Rails.env.to_sym]
  end
end