class TermsController < ApplicationController
  def chalkler
    @meta_title = 'Terms'
    @page_subtitle = 'Chalkle Website'
    @page_title = 'Terms of Use for Chalklers'
  end

  def provider
    load_channel
    if @channel.id.blank? && current_user.authenticated?
      @channel = current_user.channels.first || @channel
    end
    @meta_title = 'Channel Terms'
    @page_subtitle = 'Chalkle Website'
    if false #TODO: customize terms per channel @channel.name.present?
      @page_title = @channel.name+': Terms and Conditions'
      @page_context_links = Hash.new
    else
      @page_title = 'Channel: Terms and Conditions' 
    end
  end

  def teacher
    @meta_title = 'Teacher Terms'
    @page_subtitle = 'Chalkle Website'
    @page_title = 'Terms of Use for Teachers'
  end
end