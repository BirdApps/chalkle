class RemoveTldFromUrlName < ActiveRecord::Migration
  class Provider < ActiveRecord::Base
  end

  def up
    Provider.all.each do |provider|
      provider.url_name = provider.url_name.gsub('.chalkle.com', '')
      provider.save!
    end
  end

  def down
  end
end
