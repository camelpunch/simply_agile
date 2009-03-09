require File.join(File.dirname(__FILE__), 'projects')
class Iterations < ObjectMother
  truncate_iteration

  define_iteration(:erroneous_iteration,
                   :name => 'Erroneous Iteration',
                   :project => Projects.simply_agile)
end
