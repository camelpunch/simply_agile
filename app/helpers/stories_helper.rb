module StoriesHelper

  def story_breadcrumbs(story)
    output = <<-XML
    <li class="first-child project">#{link_to(h(@project), @project)}</li>
    XML

    if @story.iteration_id?
      output << <<-XML2
    <li class="iteration">#{link_to(@story.iteration, [@project, @story.iteration])}</li>
XML2
    end

    output
  end
end
