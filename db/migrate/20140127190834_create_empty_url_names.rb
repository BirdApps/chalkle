class CreateEmptyUrlNames < ActiveRecord::Migration
  class Provider < ActiveRecord::Base
  end

  def up
    Provider.where("url_name IS NULL OR url_name = ''").each do |provider|
      provider.url_name = provider.name.gsub(' ', '').downcase
      provider.save
    end
  end

  def down
  end
end
