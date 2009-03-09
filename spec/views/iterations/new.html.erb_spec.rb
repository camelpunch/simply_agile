require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/iterations/new" do
  before(:each) do
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

  it "should set the story attributes from the assigned iteration's stories"
end
