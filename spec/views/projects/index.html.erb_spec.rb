require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/projects/index" do

  before :each do
    assigns[:current_organisation] = mock_model Organisation
    @projects = [ mock_model(Project) ]
  end

  describe "with projects" do
    before :each do
      assigns[:current_organisation].stub!(:projects).and_return(@projects)
      render 'projects/index'
    end

    it_should_behave_like "a standard view"

    it "should have a list" do
      response.should have_tag('ol')
    end
  end

  describe "without projects" do
    before :each do
      assigns[:current_organisation].stub!(:projects).and_return([])
      render 'projects/index'
    end

    it_should_behave_like "a standard view"
  end
end
