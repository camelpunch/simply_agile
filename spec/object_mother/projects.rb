require File.join(File.dirname(__FILE__), 'organisations')
class Projects < ObjectMother
  truncate_project

  define_project(:simply_agile, 
                 :name => 'Simply Agile',
                 :organisation => Organisations.jandaweb)

end
