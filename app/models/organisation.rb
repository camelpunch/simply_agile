class Organisation < ActiveRecord::Base
  PAYMENT_LOGIN_GRACE_PERIOD = 7 # days

  has_many :projects
  has_many :stories, :through => :projects
  has_many :iterations, :through => :projects
  has_many :organisation_members
  has_many :users, :through => :organisation_members
  has_one :payment_method

  def to_s
    name || "New Organisation"
  end

  def has_payment_method_prompt?
    if payment_method && (payment_method.has_expired? ||
                          payment_method.has_failed?)
      true
    elsif created_at > PAYMENT_LOGIN_GRACE_PERIOD.days.ago
      false
    else
      true
    end
  end
end
