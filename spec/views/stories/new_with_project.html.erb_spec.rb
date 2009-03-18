require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/new_with_project" do
  before(:each) do
    @project = mock_model Project
    @story = mock_model(Story, 
                        :name => '',
                        :content => '',
                        :new_record? => true)
    assigns[:project] = @project
    assigns[:story] = @story

    assigns[:current_user] = mock_model(User, :projects => [@project])

    render 'stories/new_with_project'
  end
  
  it_should_behave_like "a standard view"

  it "should have a form for creating a story" do
    response.should have_tag('form[action=?][method=?]', stories_path, 'post')
  end

end
