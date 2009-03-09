require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/projects/show" do

  before :each do
    @project = mock_model(Project, 
                          :stories => [],
                          :iterations => [],
                          :name => '')
    assigns[:project] = @project

    render 'projects/show'
  end

  it_should_behave_like "a standard view"
end
