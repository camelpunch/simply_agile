require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

[
  HomeController,
  IterationsController,
  ProjectsController,
  StoriesController,
  AcceptanceCriteriaController,
].each do |klass|

  describe klass do
    it "should have the login_required filter" do
      klass.filter_chain.map(&:method).should include(:login_required)
    end
  end

end

