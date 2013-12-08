unless Rails.env.test? or Rails.env.cucumber?
  require 'unf'
  require 'fog'
  require 'carrierwave/storage/fog'

  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => 'AKIAIDJYDPCGQX3QSGBQ',
      :aws_secret_access_key  => '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',
      :region                 => 'ap-southeast-2',
    }
    config.fog_directory  = "chalkle-#{Rails.env}"
    config.cache_dir = Rails.root.join('tmp', 'uploads')
  end
end