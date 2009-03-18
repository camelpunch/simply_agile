require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/projects/show_guidance" do

  before :each do
    @project = mock_model(Project, 
                          :stories => [],
                          :iterations => [],
                          :name => '',
                          :description => '')
    assigns[:project] = @project

    render 'projects/show_guidance'
  end

  it_should_behave_like "guidance"
end
