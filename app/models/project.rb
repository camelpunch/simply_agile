class Project < ActiveRecord::Base
  attr_protected :organisation_id

  validates_presence_of :name, :organisation_id

  belongs_to :organisation
  has_many :iterations, :dependent => :destroy
  has_many :stories, :dependent => :destroy
  has_many(:available_stories, 
           :class_name => 'Story',
           :conditions => 'iteration_id IS NULL')

  def validate
    if (organisation && 
        organisation.projects.count >= organisation.payment_plan.project_limit)
      errors.add(:organisation, "project limit reached")
    end
  end

  def to_s
    name || "New Project"
  end

  def priorities=(priorities)
    priorities.each_pair do |id, priority|
      stories.update(id, :priority => priority)
    end
  end
end
