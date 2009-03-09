require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/iterations/new" do
  describe "first visit" do
    before :each do
      @story = Stories.iteration_planning!
      assigns[:project] = @story.project
      assigns[:iteration] = @story.project.iterations.build
      render 'iterations/new'
    end

    it_should_behave_like "a standard view"

    it "should have a form to create an iteration" do
      response.should have_tag('form[action=?][method=?]', 
                               project_iterations_path(assigns[:project]),
                             'post')
    end
  end

  describe "on error" do
    before :each do
      @story = Stories.iteration_planning_included!
      @iteration = mock_model(Iteration, 
                              :duration => '',
                              :name => '', 
                              :stories => [@story])
      assigns[:project] = @story.project
      assigns[:iteration] = @iteration
      render 'iterations/new'
    end

    it "should set the included value for the assigned stories" do
      selector = "input#stories_#{@story.id}_include[checked='checked']"
      response.should have_tag(selector)
    end

    it "should set the estimate value" do
      selector = "input#stories_#{@story.id}_estimate[value=#{@story.estimate}]"
      response.should have_tag(selector)
    end
  end
end
