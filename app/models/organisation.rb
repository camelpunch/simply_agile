class PaymentNotDueException < StandardError; end
class NoPaymentMethod < StandardError; end

class Organisation < ActiveRecord::Base
  PAYMENT_LOGIN_GRACE_PERIOD = 7 # days

  has_many :projects
  has_many :stories, :through => :projects
  has_many :iterations, :through => :projects
  has_many :projects
  has_many :stories, :through => :projects
  has_many :iterations, :through => :projects
  has_many :members, :class_name => 'OrganisationMember'
  has_many :users, :through => :members
  has_one :payment_method
  belongs_to :payment_plan

  attr_accessible :name, :payment_plan_id, :users

  validates_presence_of :name
  validates_presence_of :payment_plan_id,
    :message => 'must be selected'

  validates_exclusion_of :suspended, :in => [true]

  default_scope :order => 'name'

  named_scope :active, 
    :conditions => ['suspended IS NULL OR suspended = ?', false]

  def to_s
    name || "New Organisation"
  end

  def has_valid_payment_method?
    return true if next_payment_date.blank?

    if payment_method && (payment_method.has_expired? ||
                          payment_method.has_failed?)
      false
    elsif created_at < PAYMENT_LOGIN_GRACE_PERIOD.days.ago
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
      :amount => payment_plan.price * 100,
      :description => name
    )

    if repeat.successful?
      self.update_attribute(:next_payment_date, next_payment_date >> 1)
    end
  end
end
