require File.join(File.dirname(__FILE__), 'projects')
class Iterations < ObjectMother
  truncate_iteration

  def self.create_iteration!(attributes = {})
    iteration = Iteration.new({
      :duration => 30,
      :stories => [Stories.create_story!]
    }.merge(attributes))

    iteration.project = 
      if attributes[:project]
        then attributes[:project]
      else Projects.simply_agile
      end

    iteration.save!
    iteration
  end

  def self.first_iteration
    create_iteration!(
      :name => 'First Iteration',
      :duration => 7,
      :stories => [Stories.iteration_planning, Stories.acceptance_criteria]
    )
  end

  def self.active_iteration
    story = Stories.create_story! :project => Projects.simply_agile!
    create_iteration!(
      :name => 'Active Iteration',
      :duration => 7,
      :project => story.project,
      :start_date => Date.yesterday,
      :end_date => 6.days.from_now.to_date,
      :initial_estimate => 4,
      :stories => [story]
    )
  end

  def self.recently_finished_iteration
    story = Stories.create_story! :project => Projects.simply_agile!
    create_iteration!(
      :name => 'Active Iteration',
      :duration => 10,
      :start_date => (Date.today - 10),
      :initial_estimate => 4,
      :stories => [story]
    )
  end

  # update this when we have a definition for a finished iteration
  def self.finished_iteration
    story = Stories.create_story! :project => Projects.simply_agile!
    create_iteration!(
      :name => 'Finished Iteration',
      :duration => 7,
      :project => Projects.simply_agile,
      :start_date => (Date.today - 15),
      :initial_estimate => 4,
      :stories => [story]
    )
  end

  define_iteration(:erroneous_iteration,
    :name => 'Erroneous Iteration',
    :project => Projects.simply_agile)
end
