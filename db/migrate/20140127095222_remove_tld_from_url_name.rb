class RemoveTldFromUrlName < ActiveRecord::Migration
  class Channel < ActiveRecord::Base
  end

  def up
    Channel.all.each do |channel|
      channel.url_name = channel.url_name.gsub('.chalkle.com', '')
      channel.save!
    end
  end

  def down
  end
end
