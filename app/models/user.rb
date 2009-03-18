class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessor :organisation_name
  attr_accessor :sponsor

  belongs_to :organisation
  has_many :organisation_sponsors
  has_many :projects, :through => :organisation

  validates_email_format_of :email_address
  validates_uniqueness_of :email_address
  validates_presence_of :organisation_id, :unless => :signup?
  validates_presence_of :organisation_name, 
    :if => lambda { |user| user.signup? && user.organisation.nil? }
  validates_presence_of :password, :on => :create, :if => :signup?

  named_scope :valid, 
    :conditions => ['verify_by IS NULL or verify_by > ?', Date.today]

  DAYS_UNTIL_UNVERIFIED = 7
  VERIFICATION_TOKEN_LENGTH = 6

  def before_create
    if signup?
      self.encrypted_password ||= hash_password(password)
      self.verified ||= false
      self.verification_token ||= generate_verification_token
      self.verify_by ||= Date.today + DAYS_UNTIL_UNVERIFIED
    end
    
    self.organisation ||= Organisation.create!(:name => organisation_name)
  end

  def after_create
    debugger if $debug
    unless signup?
      self.organisation_sponsors.create(
        :organisation => organisation,
        :sponsor_id => sponsor.id
      )
    end
  end

  def self.find_by_email_address_and_password(email_address, password)
    find_by_email_address_and_encrypted_password(email_address,
      hash_password(password))
  end

  def verify
    self.update_attributes!(:verify_by => nil, :verified => true)
  end

  def signup?
    sponsor.nil? && organisation_sponsors.empty?
  end

  def acknowledged?
    organisation_sponsors.empty?
  end

  protected

  def self.hash_password(plaintext)
    Digest::SHA1.hexdigest(plaintext)
  end

  def hash_password(plaintext)
    self.class.hash_password(plaintext)
  end

  def generate_verification_token
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    token = ''
    VERIFICATION_TOKEN_LENGTH.times { token << chars[rand(chars.length)] }
    token
  end
end
