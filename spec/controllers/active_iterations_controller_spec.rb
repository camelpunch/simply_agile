require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveIterationsController do
  before :each do
    login
    setup_project
    @story = Stories.create_story!(:project => @project)
    @iteration = Iterations.create_iteration!(
      :project => @project,
      :stories => [@story]
    )
  end

  describe "get iteration" do
    before :each do
      controller.stub!(:params).and_return(
        :iteration_id => @iteration.id.to_s
      )
    end

    it "should set the instance variable" do
      controller.send(:get_iteration)
      controller.instance_variable_get("@iteration").should == @iteration
    end
  end

  describe "create" do
    def do_call
      post :create, :iteration_id => @iteration.id
    end

    it "should start an iteration" do
      do_call
      @iteration.reload
      @iteration.start_date.should_not be_nil
    end

    it "should redirect to Iterations#show" do
      do_call
      response.should redirect_to(project_iteration_path(@project, @iteration))
    end
  end
end
