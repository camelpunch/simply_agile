require File.join(File.dirname(__FILE__), 'organisations')
class Projects < ObjectMother
  truncate_project

  def self.project_prototype
    {
      :name => 'protototo',
      :organisation => Organisations.create_organisation!
    }
  end

  define_project(:simply_agile, 
                 :name => 'Simply Agile',
                 :organisation => Organisations.jandaweb)

end
