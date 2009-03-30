class StoryActionObserver < ActiveRecord::Observer
  observe :story_team_member, :acceptance_criterion, :story

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

    debugger
    StoryAction.find_or_create_by_user_id_and_story_id_and_iteration_id(
      user.id, 
      story.id, 
      iteration.id
    )
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
