require File.join(File.dirname(__FILE__), 'projects')
class Iterations < ObjectMother
  truncate_iteration

  def self.first_iteration
    Iteration.create!(
      :name => 'First Iteration',
      :duration => 7,
      :project => Projects.simply_agile,
      :stories => [Stories.iteration_planning, Stories.acceptance_criteria]
    )
  end

  define_iteration(:erroneous_iteration,
    :name => 'Erroneous Iteration',
    :project => Projects.simply_agile)
end
