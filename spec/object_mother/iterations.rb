require File.join(File.dirname(__FILE__), 'projects')
class Iterations < ObjectMother
  truncate_iteration

  def self.iteration_prototype
    {
      :project => Projects.simply_agile,
      :duration => 30,
    }
  end

  define_iteration(:erroneous_iteration,
                   :name => 'Erroneous Iteration',
                   :project => Projects.simply_agile)
end
