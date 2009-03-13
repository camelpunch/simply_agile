require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/backlog_guidance" do

  before :each do
    assigns[:current_user] = mock_model User, :organisation => 'asdf'
    @project = mock_model(Project)
    assigns[:project] = @project
  end

  before :each do
    render 'stories/backlog_guidance'
  end

  it_should_behave_like "a standard view"

  it "should have guidance" do
    response.should have_tag('.guidance')
  end
end
