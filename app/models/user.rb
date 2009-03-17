class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessor :organisation_name
  belongs_to :organisation
  has_many :projects, :through => :organisation

  validates_email_format_of :email_address
  validates_uniqueness_of :email_address
  validates_presence_of :organisation_id,
    :if => lambda { |user| user.organisation_name.nil? }
  validates_presence_of :organisation_name,
    :if => lambda { |user| user.organisation.nil? }
  validates_presence_of :password, :on => :create

  VERIFICATION_TOKEN_LENGTH = 6

  def before_create
    self.organisation ||= Organisation.create!(:name => organisation_name)
    self.encrypted_password ||= hash_password(password)
    self.verified ||= false
    self.verification_token ||= generate_verification_token
  end

  def self.find_by_email_address_and_password(email_address, password)
    find_by_email_address_and_encrypted_password(email_address,
      hash_password(password))
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
