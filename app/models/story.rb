class Story < ActiveRecord::Base

  module Status
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    TESTING = "testing"
    COMPLETE = "complete"
  end

  attr_accessor :include
  belongs_to :iteration
  belongs_to :project

  has_many(:acceptance_criteria, 
           :order => 'criterion',
           :dependent => :destroy)

  named_scope :assigned_or_available_for, lambda {|iteration|
    {
      :conditions => ['iteration_id = ? OR iteration_id IS NULL', iteration.id]
    }
  }

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

  def update_status_from_acceptance_criteria
    if acceptance_criteria.uncompleted.empty? &&
        status == Status::PENDING || status == Status::IN_PROGRESS
      self.update_attributes(:status => Status::TESTING)
    elsif status == Status::TESTING || status == Status::COMPLETE
      self.update_attributes(:status => Status::IN_PROGRESS)
    end
  end
end
