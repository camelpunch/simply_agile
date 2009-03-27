require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/backlog" do

  before :each do
    assigns[:current_user] = mock_model User, :organisation => 'asdf'
    @stories = []
    @project = mock_model(Project, :stories => @stories)
    @story = mock_model(Story, 
                        :status => 'pending',
                        :team_members => [],
                        :acceptance_criteria => [],
                        :iteration => nil,
                        :estimate? => true,
                        :estimate => 2,
                        :project => @project,
                        :content => '', 
                        :priority => 1)
    assigns[:project] = @project
  end

  before :each do
    @stories.stub!(:backlog).and_return([@story])
    render 'stories/backlog'
  end

  it_should_behave_like "a standard view"

  it "should have a list" do
    response.should have_tag('ol')
  end
end
