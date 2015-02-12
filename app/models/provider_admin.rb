class ProviderAdmin < ActiveRecord::Base
  attr_accessible :chalkler, :chalkler_id, :provider, :provider_id, :email

  EMAIL_VALIDATION_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_many   :courses, through: :provider
  belongs_to :provider
  belongs_to :chalkler

  validates_presence_of :provider_id
  validates_presence_of :email, message: 'Email cannot be blank'
  validates :pseudo_chalkler_email, allow_blank: true, format: { with: EMAIL_VALIDATION_REGEX, :message => "That doesn't look like a real email"  }

  def name
    chalkler ? chalkler.name : email
  end

  def avatar
    chalkler ? chalkler.avatar : nil
  end

  def email
    if chalkler.present?
      chalkler.email
    else
      pseudo_chalkler_email
    end
  end

  def email=(email)
    self.chalkler = Chalkler.exists email
    self.pseudo_chalkler_email = email unless chalkler.present?
    #TODO: email chalkler or non-chalkler to tell them they are an admin
  end

  def self.csv_for(provider_admins)
    fields_for_csv = %w{ id name email provider_name }
    CSV.generate do |csv|
      csv << fields_for_csv.map(&:to_s)

      provider_admins.each do |provider_admin|
        csv << fields_for_csv.map{ |field| provider_admin.send(field) }
      end
      
    end
  end

  def provider_name
    provider.name if provider
  end

end
