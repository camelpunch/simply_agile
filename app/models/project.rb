class Project < ActiveRecord::Base
  attr_protected :organisation_id

  belongs_to :organisation
  has_many :iterations, :dependent => :destroy
  has_many :stories, :dependent => :destroy
  has_many(:available_stories, 
           :class_name => 'Story',
           :conditions => 'iteration_id IS NULL')

  def to_s
    name || "New Project"
  end
end
