require 'carrierwave'
require 'avatar_uploader'
class ChalklerPreferences
  include ActiveAttr::Model

  attr_accessor :chalkler, :email, :email_frequency :bio, :phone_number, :visible, :avatar, :address, :name

  validates :email, allow_blank: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, :message => "Email must be in the correct format"}

  def initialize(chalkler)
    @chalkler         = chalkler
    @name            = @chalkler.name
    @email            = @chalkler.email
    @email_frequency  = @chalkler.email_frequency
    @bio              = @chalkler.bio
    @phone_number     = @chalkler.phone_number
    @visible          = @chalkler.visible
    @avatar           = @chalkler.avatar
    @address          = @chalkler.address
    
  end

  def update_attributes(params)
    @name             = params[:name]
    @bio              = params[:bio]
    @phone_number     = params[:phone_number]
    @visible          = params[:visible]
    @avatar           = params[:avatar]
    @address          = params[:address]
    @email            = params[:email]
    @email_frequency  = params[:email_frequency]
    valid? && persist_to_chalkler
  end


  private

    def persist_to_chalkler
      @chalkler.name             = @name
      @chalkler.bio              = @bio
      @chalkler.phone_number     = @phone_number
      @chalkler.visible          = @visible
      @chalkler.avatar           = @avatar
      @chalkler.address          = @address
      @chalkler.email            = @email
      @chalkler.email_frequency  = @email_frequency
      @chalkler.save
    end
end
