require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/new_without_project" do
  before(:each) do
    @story = mock_model(Story, 
                        :project_id => nil,
                        :name => '',
                        :content => '',
                        :new_record? => true)
    assigns[:current_organisation] = mock_model(Organisation, :projects => [])
    assigns[:story] = @story
    render 'stories/new_without_project'
  end
  
  it "should have a form for creating a story" do
    response.should have_tag('form[action=?][method=?]',
                             stories_path,
                             'post')
  end
  
end
