class Story < ActiveRecord::Base
  belongs_to :iteration
  belongs_to :project

  has_many(:acceptance_criteria, 
           :order => 'criterion',
           :dependent => :destroy)

  validates_presence_of :name, :content, :project_id

  validates_uniqueness_of :name, :scope => :project_id

  def validate
    if iteration && project && (iteration.project_id != project_id)
      errors.add(:iteration_id, "does not belong to the story's project")
    end
  end

  named_scope :incomplete

  def to_s
    name || "New Story"
  end
end
