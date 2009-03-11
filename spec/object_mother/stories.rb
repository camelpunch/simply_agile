require File.join(File.dirname(__FILE__), 'projects')
require File.join(File.dirname(__FILE__), 'iterations')
class Stories < ObjectMother
  truncate_story

  def self.story_prototype
    count = Story.count
    {
      :name => "Story #{count + 1}",
      :project => Projects.simply_agile,
      :content => 'asdf',
    }
  end

  define_story(:iteration_planning, :name => 'Iteration Planning')
  define_story(:acceptance_criteria, :name => 'Acceptance Criteria')
  define_story(:iteration_planning_included, 
               :name => 'Iteration Planning Included',
               :estimate => 4,
               :iteration => Iterations.erroneous_iteration)
end
