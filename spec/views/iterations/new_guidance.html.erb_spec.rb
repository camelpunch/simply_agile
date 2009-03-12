require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/iterations/new_guidance" do
  before :each do
    @project = mock_model(Project)
    @iteration = mock_model(Iteration)
    assigns[:project] = @project
    assigns[:iteration] = @iteration

    render 'iterations/new_guidance'
  end

  it_should_behave_like "guidance"
end
