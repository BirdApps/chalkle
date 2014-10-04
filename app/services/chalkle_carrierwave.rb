require 'carrierwave'

if Rails.env.test? or Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.root = Rails.root.join('public/system')
    #config.enable_processing = false
  end
else
  #require 'chalkle_s3'
  CarrierWave.configure do |config|
    config.root = Rails.root.join('public')
    #config.enable_processing = false
  end

end
