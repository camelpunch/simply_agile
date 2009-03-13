class Story < ActiveRecord::Base
  attr_accessor :include
  belongs_to :iteration
  belongs_to :project

  has_many(:acceptance_criteria, 
           :order => 'criterion',
           :dependent => :destroy)

  default_scope :order => 'priority, name'

  named_scope :assigned_or_available_for, lambda {|iteration|
    {
      :conditions => ['iteration_id = ? OR iteration_id IS NULL', iteration.id]
    }
  }

  named_scope :backlog, 
    :conditions => ['status = ? AND iteration_id IS NULL', 'pending']

  validates_presence_of :name, :content, :project_id

  validates_uniqueness_of :name, :scope => :project_id

  def validate
    if iteration && project && (iteration.project_id != project_id)
      errors.add(:iteration_id, "does not belong to the story's project")
    end

    # iteration id changed on a story
    if iteration_id_changed? && !changes['iteration_id'][0].nil?
      errors.add(:iteration_id, "cannot be changed")
    end
  end

  named_scope :incomplete, :conditions => ['status != ?', 'complete']

  def to_s
    name || "New Story"
  end
end
