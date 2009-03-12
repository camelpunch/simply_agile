class Organisation < ActiveRecord::Base
  has_many :projects
  has_many :iterations, :through => :projects
  has_many :users

  def to_s
    name || "New Organisation"
  end
end
