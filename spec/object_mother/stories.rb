require File.join(File.dirname(__FILE__), 'projects')
class Stories < ObjectMother
  truncate_story

  def self.story_prototype
    {
      :project => Projects.simply_agile
    }
  end

  define_story(:iteration_planning,
               :name => 'Iteration Planning')
end
