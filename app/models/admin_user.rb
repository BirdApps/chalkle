class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :name, :role, :email, :password, :password_confirmation, :remember_me, :group_ids

  has_many :group_admins
  has_many :groups, :through => :group_admins
  has_many :lessons, :through => :groups, :uniq => true
  has_many :chalklers, :through => :groups, :uniq => true
  has_many :bookings, :through => :groups, :uniq => true
  has_many :categories, :through => :groups, :uniq => true
  has_many :payments, :through => :bookings

  after_create { |admin| admin.send_reset_password_instructions }
  before_destroy :raise_if_last

  def password_required?
    new_record? ? false : super
  end

  def raise_if_last
    if AdminUser.count < 2
      raise "Can't delete last admin user"
    end
  end

end
