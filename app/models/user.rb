class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessor :organisation_name
  attr_accessor :sponsor

  has_many :organisation_memberships
  has_many :organisations, :through => :organisation_memberships
  has_many :organisation_sponsors
  has_many :projects, :through => :organisation

  validates_email_format_of :email_address
  validates_uniqueness_of :email_address
  validates_presence_of :organisation_name, :on => :create,
    :if => lambda { |user| user.signup? && user.organisations.empty? }
  validates_presence_of :password, :if => :password_required?

  default_scope :order => 'email_address'

  named_scope :valid, 
    :conditions => ['verify_by IS NULL or verify_by > ?', Date.today]

  DAYS_UNTIL_UNVERIFIED = 7
  TOKEN_LENGTH = 6

  def before_create
    if signup?
      self.verified ||= false
      self.verification_token ||= generate_token
      self.verify_by ||= Date.today + DAYS_UNTIL_UNVERIFIED
    else
      self.acknowledgement_token ||= generate_token
    end

    if (organisation_name)
      self.organisations.create!(:name => organisation_name)
    end
  end

  def before_save
    unless password.nil? || (new_record? && ! signup?)
      self.encrypted_password ||= hash_password(password)
    end
  end

  def after_create
    unless signup?
      self.organisation_sponsors.create!(
        :organisation => organisations.first,
        :sponsor_id => sponsor.id
      )
    end
  end

  def self.find_by_email_address_and_password(email_address, password)
    find_by_email_address_and_encrypted_password(email_address,
      hash_password(password))
  end

  def verify(options)
    return false unless options[:token] == verification_token
    self.update_attributes!(:verify_by => nil, :verified => true)
    true
  end

  def signup?
    sponsor.nil? && organisation_sponsors.empty?
  end

  def acknowledged?
    organisation_sponsors.empty?
  end

  def acknowledge(options)
    return false unless options[:token] == acknowledgement_token

    return false unless self.update_attributes(
      :acknowledgement_token => nil,
      :verified => true,
      :password => options[:password]
    )
    
    self.organisation_sponsors.first.destroy
  end

  protected

  def password_required?
    encrypted_password.blank? && ((! new_record?) || signup?)
  end

  def self.hash_password(plaintext)
    Digest::SHA1.hexdigest(plaintext)
  end

  def hash_password(plaintext)
    self.class.hash_password(plaintext)
  end

  def generate_token
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    token = ''
    TOKEN_LENGTH.times { token << chars[rand(chars.length)] }
    token
  end
end
