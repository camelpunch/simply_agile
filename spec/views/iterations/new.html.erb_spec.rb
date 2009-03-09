require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/iterations/new" do
  before(:each) do
    @story = mock_model(Story, :name => 'asdf', :content => '')
    assigns[:project] = mock_model(Project,
                                   :stories => [@story])
    assigns[:iteration] = mock_model(Iteration, 
                                     :name => '',
                                     :duration => '',
                                     :new_record? => true)
    render 'iterations/new'
  end
  
  it_should_behave_like "a standard view"

  it "should have a form to create an iteration" do
    response.should have_tag('form[action=?][method=?]', 
                             project_iterations_path(assigns[:project]),
                             'post')
  end

  it "should set the story attributes from the assigned iteration's stories"
end
