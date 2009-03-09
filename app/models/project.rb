class Project < ActiveRecord::Base
  attr_protected :organisation_id

  belongs_to :organisation
  has_many :iterations, :dependent => :destroy
  has_many :stories, :dependent => :destroy

  def to_s
    name || "New Project"
  end
end
