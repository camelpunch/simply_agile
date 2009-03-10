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

    # iteration id changed on a story
    if iteration_id_changed? && !changes['iteration_id'][0].nil?
      errors.add(:iteration_id, "cannot be changed")
    end
  end

  def to_s
    name || "New Story"
  end
end
