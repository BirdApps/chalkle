class TermsController < ApplicationController
  def chalkler
    @meta_title = 'Terms'
    @page_subtitle = 'Chalkle Website'
    @page_title = 'Terms of Use for Chalklers'
  end

  def privacy
    chalkler
  end

  def provider
    load_provider
    if @provider.id.blank? && current_user.authenticated?
      @provider = current_user.providers.first || @provider
    end
    @meta_title = 'Provider Terms'
    @page_subtitle = 'Chalkle Website'
    if false #TODO: customize terms per provider @provider.name.present?
      @page_title = @provider.name+': Terms and Conditions'
      @page_context_links = Hash.new
    else
      @page_title = 'Provider: Terms and Conditions' 
    end
  end

  def teacher
    @meta_title = 'Teacher Terms'
    @page_subtitle = 'Chalkle Website'
    @page_title = 'Terms of Use for Teachers'
  end
end