module StoriesHelper

  def story_classes(story)
    "story #{story.status} #{story.team_members.empty? ? '' : 'with_team'}"
  end

  def story_breadcrumbs(story)
    output = <<-XML
    <li class="project">#{link_to(h(@project), @project)}</li>
    XML

    if @story.iteration_id?
      output << <<-XML2
    <li class="iteration">#{link_to(@story.iteration, [@project, @story.iteration])}</li>
XML2
    end

    output
  end
end
