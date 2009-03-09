require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/new" do
  before(:each) do
    @project = mock_model Project
    @story = mock_model(Story, 
                        :name => '',
                        :content => '',
                        :new_record? => true)
    assigns[:project] = @project
    assigns[:story] = @story
    render 'stories/new'
  end
  
  it "should have a form for creating a story" do
    response.should have_tag('form[action=?][method=?]',
                             project_stories_path(@project),
                             'post')
  end
  
end
