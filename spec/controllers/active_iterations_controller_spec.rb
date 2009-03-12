require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveIterationsController do
  before :each do
    login
  end

  describe "get iteration" do
    before :each do
      @iteration = mock_model(Iteration)
      @iterations = mock('Collection')
      @iterations.stub!(:find).with(@iteration.id.to_s).and_return(@iteration)
      @organisation.stub!(:iterations).and_return(@iterations)
      
      controller.stub!(:params).and_return(
        :iteration_id => @iteration.id.to_s
      )
    end

    it "should try to find the iteration" do
      @iterations.should_receive(:find).with(@iteration.id.to_s)
      controller.send(:get_iteration)
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

    before :each do
      @project = mock_model(Project)
      @iteration = mock_model(Iteration, :project => @project)
      @iteration.stub!(:start)
      controller.stub!(:get_iteration)
      controller.instance_variable_set("@iteration", @iteration)
    end

    it "should assign the iteration" do
      controller.should_receive(:get_iteration)
      do_call
    end

    it "should call start on the iteration" do
      @iteration.should_receive(:start)
      do_call
    end

    it "should redirect to Iterations#show" do
      do_call
      response.should redirect_to(project_iteration_path(@project, @iteration))
    end
  end
end
