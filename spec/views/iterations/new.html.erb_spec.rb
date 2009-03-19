require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/iterations/new" do
  before :each do
    @story = mock_model(Story,
                        :name => '',
                        :content => '',
                        :estimate => '',
                        :acceptance_criteria => [],
                        :iteration_id? => false,
                        :project => @project)
    @project = mock_model(Project)
    @iteration = mock_model(Iteration, 
                            :duration => '',
                            :name => '',
                            :stories => [],
                            :new_record? => true)
    assigns[:project] = @project
    assigns[:iteration] = @iteration
    assigns[:stories] = [@story]
  end

  describe "first visit" do
    before :each do
      render 'iterations/new'
    end

    it_should_behave_like "a standard view"

    it "should have a form to create an iteration" do
      response.should have_tag('form[action=?][method=?]', 
                               project_iterations_path(@project),
                               'post')
    end

    it "should display available stories" do
      response.should have_tag('#stories_available')
    end
  end

  describe "on error" do
    before :each do
      @iteration.stub!(:stories).and_return([@story])
      render 'iterations/new'
    end

    it "should set the included value for the assigned stories" do
      selector = "input#stories_#{@story.id}_include[checked='checked']"
      response.should have_tag(selector)
    end

    it "should set the estimate value" do
      selector = "input#stories_#{@story.id}_estimate[value=#{@story.estimate}]"
      response.should have_tag(selector)
    end
  end
end
