module StoriesHelper

  def story_classes(story)
    "story #{story.status} #{story.team_members.empty? ? '' : 'with_team'}"
  end

  def story_breadcrumbs(story)
    crumbs = [ link_to(h(@project), @project) ]

    if @story.iteration_id?
      crumbs << link_to(@story.iteration, [@project, @story.iteration])
    end

    crumbs
  end
end
