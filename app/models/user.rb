class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessor :organisation_name
  belongs_to :organisation
  has_many :projects, :through => :organisation

  validates_presence_of :organisation_id

  def self.find_by_email_address_and_password(email_address, password)
    encrypted_password = Digest::SHA1.hexdigest(password)
    find_by_email_address_and_encrypted_password(email_address,
                                                 encrypted_password)
  end
end
