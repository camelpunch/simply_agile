class Organisation < ActiveRecord::Base
  attr_protected :user_ids

  has_many :projects
  has_many :stories, :through => :projects
  has_many :iterations, :through => :projects
  has_many :organisation_members
  has_many :users, :through => :organisation_members

  validates_presence_of :name
  validates_presence_of :payment_plan_id,
    :message => 'must be selected'

  def to_s
    name || "New Organisation"
  end
end
