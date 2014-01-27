class CreateEmptyUrlNames < ActiveRecord::Migration
  class Channel < ActiveRecord::Base
  end

  def up
    Channel.where("url_name IS NULL OR url_name = ''").each do |channel|
      channel.url_name = channel.name.gsub(' ', '').downcase
      channel.save
    end
  end

  def down
  end
end
