require 'carrierwave'

if Rails.env.test? or Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.storage = :file
    config.root = Rails.root.join('public/system')
    #config.enable_processing = false
  end
else
  require 'chalkle_s3'
end
