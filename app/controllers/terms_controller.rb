class TermsController < ApplicationController
  before_filter :header_provider, only: :provider
  before_filter :header_teacher, only: :teacher
  before_filter :header_chalkler, only: :chalkler

  def chalkler
  end

  def privacy
    chalkler
  end

  def provider
  end

  def teacher
    @meta_title = 'Terms'
    @page_subtitle = 'Chalkle Website'
    @page_title = 'Terms of Use for Chalklers'
  end

  private
    def header_chalkler
    end

    def header_teacher
      @meta_title = 'Teacher Terms'
      @page_subtitle = 'Chalkle Website'
      @page_title = 'Terms of Use for Teachers'
    end

    def header_provider
      @meta_title = 'Provider Terms'
      @page_subtitle = 'Chalkle Website'
      @page_title = 'Provider: Terms and Conditions'
    end
end