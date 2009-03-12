class AcceptanceCriterion < ActiveRecord::Base
  validates_presence_of :criterion, :story_id

  validates_uniqueness_of :criterion, :scope => :story_id,
    :message => 'already assigned to story'

  def to_s
    criterion || "New Acceptance Criterion"
  end

  def complete?
    ! fulfilled_at.nil?
  end

  def complete=(value)
    if value.kind_of?(TrueClass) || value == "true"
      self.fulfilled_at ||= Time.now
    else
      self.fulfilled_at = nil
    end
  end
end
