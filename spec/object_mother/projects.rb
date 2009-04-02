require File.join(File.dirname(__FILE__), 'organisations')
class Projects < ObjectMother
  truncate_project

  class << self
    extend ActiveSupport::Memoizable

    def create_project!(attributes = {})
      project = Project.new({:name => 'protototo'}.merge(attributes))
      project.organisation = attributes[:organisation] || Organisations.create_organisation!
      project.save!
      project
    end

    def simply_agile
      project = Project.new(:name => 'Simply Agile')
      project.organisation = Organisations.jandaweb!
      project.save!
      project
    end
    memoize :simply_agile

    alias :simply_agile! :simply_agile
  end

end
