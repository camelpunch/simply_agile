class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessor :organisation_name
  belongs_to :organisation
  has_many :projects, :through => :organisation

  validates_associated :organisation, :if => lambda {  :organisation_name.blank? }

  def before_create
    self.organisation ||= Organisation.create!(:name => organisation_name)
    self.encrypted_password ||= hash_password(password)
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
end
