class StoryActionObserver < ActiveRecord::Observer
  observe :story_team_member, :acceptance_criterion

  def before_save(obj)
    return if change_should_be_ignored?(obj)

    story = nil
    if obj.is_a? Story
      story = obj
    elsif obj.respond_to? :story
      story = obj.story
    else
      raise "don't know what to do with #{obj.inspect}"
    end

    user = obj.current_user
    iteration = story.iteration

    StoryAction.create!(:user => user, :story => story, :iteration => iteration)
  end

  def change_should_be_ignored?(obj)
    ignore = false

    ignore ||= obj.is_a?(AcceptanceCriterion) &&
      ! obj.changes.keys.include?("fulfilled_at")

    ignore ||= obj.is_a?(Story) &&
      ! obj.changes.keys.include?("status")

    ignore
  end
end
