require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/iterations/edit" do
  before :each do
    @story = mock_model(Story,
                        :name => '',
                        :content => '',
                        :estimate => '',
                        :acceptance_criteria => [],
                        :iteration_id? => false,
                        :iteration => nil,
                        :project => @project)
    @project = mock_model(Project,
                          :stories => @stories)
    @iteration = mock_model(Iteration, 
                            :duration => '',
                            :name => '',
                            :stories => [])
    assigns[:stories] = [@story]
  end

  describe "first visit" do
    before :each do
      assigns[:project] = @project
      assigns[:iteration] = @iteration
      render 'iterations/edit'
    end

    it_should_behave_like "a standard view"

    it "should have a form to update the iteration" do
      response.should have_tag('form[action=?][method=?]', 
                               project_iteration_path(@project, @iteration),
                               'post')
    end
  end

  describe "on error" do
    before :each do
      @iteration.stub!(:stories).and_return([@story])
      assigns[:project] = @project
      assigns[:iteration] = @iteration
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
