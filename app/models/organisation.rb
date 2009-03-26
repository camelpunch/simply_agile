class Organisation < ActiveRecord::Base
  has_many :projects
  has_many :stories, :through => :projects
  has_many :iterations, :through => :projects
  has_many :organisation_members
  has_many :users, :through => :organisation_members

  def to_s
    name || "New Organisation"
  end
end
