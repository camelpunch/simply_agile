require File.join(File.dirname(__FILE__), 'projects')
class Iterations < ObjectMother
  truncate_iteration

  def self.iteration_prototype
    {
      :project => Projects.simply_agile,
      :duration => 30,
    }
  end

  def self.first_iteration
    Iteration.create!(
      :name => 'First Iteration',
      :duration => 7,
      :project => Projects.simply_agile,
      :stories => [Stories.iteration_planning, Stories.acceptance_criteria]
    )
  end

  def self.active_iteration
    story = Stories.create_story! :project => Projects.simply_agile!
    Iteration.create!(
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
    Iteration.create!(
      :name => 'Active Iteration',
      :duration => 7,
      :project => Projects.simply_agile,
      :start_date => (Date.today - 10),
      :initial_estimate => 4,
      :stories => [story]
    )
  end

  # update this when we have a definition for a finished iteration
  def self.finished_iteration
    story = Stories.create_story! :project => Projects.simply_agile!
    Iteration.create!(
      :name => 'Finished Iteration',
      :duration => 7,
      :project => Projects.simply_agile,
      :start_date => (Date.today - 30),
      :initial_estimate => 4,
      :stories => [story]
    )
  end

  define_iteration(:erroneous_iteration,
    :name => 'Erroneous Iteration',
    :project => Projects.simply_agile)
end
