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

  def has_payment_method_prompt?
    if payment_method && (payment_method.has_expired? ||
                          payment_method.has_failed?)
      true
    elsif created_at < PAYMENT_LOGIN_GRACE_PERIOD.days.ago
      true
    else
      false
    end
  end
end
