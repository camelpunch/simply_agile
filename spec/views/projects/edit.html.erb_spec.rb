require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/projects/edit" do

  before :each do
    @project = mock_model(Project, 
                          :stories => [],
                          :iterations => [],
                          :name => '',
                          :description => '')
    assigns[:project] = @project

    render 'projects/edit'
  end

  it_should_behave_like "a standard view"
end
