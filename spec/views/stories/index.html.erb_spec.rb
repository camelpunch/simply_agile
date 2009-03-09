require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/index" do

  before :each do
    assigns[:current_user] = mock_model User, :organisation => 'asdf'
    @stories = [ mock_model(Story) ]
    @project = mock_model(Project)
    assigns[:project] = @project
  end

  describe "with stories" do
    before :each do
      assigns[:project].stub!(:stories).and_return(@stories)
      render 'stories/index'
    end

    it_should_behave_like "a standard view"

    it "should have a list" do
      response.should have_tag('ol')
    end
  end

  describe "without stories" do
    before :each do
      assigns[:project].stub!(:stories).and_return([])
      render 'stories/index'
    end

    it_should_behave_like "a standard view"
  end
end
