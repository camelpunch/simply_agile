class AcceptanceCriterion < ActiveRecord::Base
  validates_presence_of :criterion, :story_id

  validates_uniqueness_of :criterion, :scope => :story_id,
    :message => 'already assigned to story'

  def to_s
    criterion || "New Acceptance Criterion"
  end
end
