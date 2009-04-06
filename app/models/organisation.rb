class PaymentNotDueException < StandardError; end
class NoPaymentMethod < StandardError; end

class Organisation < ActiveRecord::Base
  include RepeatBilling
  
  PAYMENT_LOGIN_GRACE_PERIOD = 7 # days

  has_many :projects
  has_many :stories, :through => :projects
  has_many :iterations, :through => :projects
  has_many :projects
  has_many :stories, :through => :projects
  has_many :iterations, :through => :projects
  has_many :members, :class_name => 'OrganisationMember'
  has_many :users, :through => :members
  has_many :payments
  has_one :payment_method
  belongs_to :payment_plan

  attr_accessible :name, :payment_plan_id, :users

  validates_presence_of :name
  validates_presence_of :payment_plan_id

  validates_exclusion_of :suspended, :in => [true]

  default_scope :order => 'suspended DESC, name'

  named_scope :active, 
    :conditions => ['suspended IS NULL OR suspended = ?', false]

  named_scope :payment_due,
    :conditions => ['next_payment_date <= ?', Date.today]

  def self.billable
    payment_due.active.delete_if { |o| o.payment_method.nil? }
  end

  def to_s
    name.to_s || "New Organisation"
  end

  def suspension_date
    next_payment_date + OrganisationSuspender::GRACE_PERIOD
  end

  def has_valid_payment_method?
    return true if next_payment_date.blank? ||
      created_at > PAYMENT_LOGIN_GRACE_PERIOD.days.ago

    if payment_method.nil?
      false
    elsif payment_method.has_expired? || payment_method.has_failed?
      false
    else
      true
    end
  end

  def take_payment
    if next_payment_date.nil? || next_payment_date > Date.today
      raise PaymentNotDueException
    end
    raise NoPaymentMethod unless has_valid_payment_method?

    repeat = Repeat.create!(
      :authorization => payment_method.repeat_payment_token,
      :amount => payment_plan.total * 100,
      :description => name,
      :organisation => self
    )

    if repeat.successful?
      self.update_attribute(:next_payment_date, next_payment_date >> 1)
    else
      payment_method.update_attribute(:has_failed, true)
      UserMailer.deliver_payment_failure(self)
    end
  end
end
