namespace :sandbox do
  def upload_file(model, name)
    wave = model.send(name)
    host = ActionMailer::Base.default_url_options[:host]
    if wave.present?
      image_path = Rails.root.join("public/system/uploads" + URI.parse(wave.url).path)

      if File.exist?(image_path)
        file = File.open(image_path)

        model.send("#{name}=", file)
        model.save!
      else
        puts "FILE NOT FOUND: #{image_path}"
      end
    end
  end

  desc "move files to s3"
  task :s3upload => :environment do
    puts "Moving files to S3"
    require 'chalkle_base_uploader'

    Channel.all.each do |record|
      upload_file record, :logo
    end

    ChannelPhoto.all.each do |record|
      upload_file record, :image
    end

    Course.all.each do |record|
      upload_file record, :course_upload_image
    end

    OmniAvatar::Avatar.all.each do |record|
      upload_file record, :image
    end
  end
end