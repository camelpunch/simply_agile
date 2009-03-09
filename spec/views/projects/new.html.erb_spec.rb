require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/projects/new" do

  before :each do
    assigns[:project] = mock_model(Project, 
                                   :name => '', 
                                   :new_record? => true)
    render 'projects/new'
  end

  it_should_behave_like "a standard view"

  it "should have a form for creating a project" do
    response.should have_tag('form[action=?][method=?]', projects_path, 'post')
  end
end
