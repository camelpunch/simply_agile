class Organisation < ActiveRecord::Base
  attr_accessible :name, :payment_plan_id, :users

  belongs_to :payment_plan
  has_many :projects
  has_many :stories, :through => :projects
  has_many :iterations, :through => :projects
  has_many :members, :class_name => 'OrganisationMember'
  has_many :users, :through => :members

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
end
