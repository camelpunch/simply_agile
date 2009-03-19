class AcceptanceCriterion < ActiveRecord::Base
  belongs_to :story
  
  validates_presence_of :criterion, :story_id

  validates_uniqueness_of :criterion, :scope => :story_id,
    :message => 'already assigned to story'

  named_scope :completed, { :conditions => 'fulfilled_at IS NOT NULL' }
  named_scope :uncompleted, { :conditions => 'fulfilled_at IS NULL' }

  def to_s
    criterion || "New Acceptance Criterion"
  end

  def complete?
    ! fulfilled_at.nil?
  end
  alias :complete :complete?

  def complete=(value)
    if value.kind_of?(TrueClass) || value == "true"
      self.fulfilled_at ||= Time.now
    else
      self.fulfilled_at = nil
    end
  end
end
