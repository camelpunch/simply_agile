require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  before :each do
    login
    @active_iterations = mock('Active Iterations')
    @iterations = mock('Iterations')
    @iterations.stub!(:active).and_return(@active_iterations)
    @organisation.stub!(:iterations).and_return(@iterations)
  end

  it "should assign the organisation" do
    controller.send(:get_organisation)
    controller.instance_variable_get("@organisation").should ==
      @organisation
  end

  it "should assign active iterations" do
    controller.instance_variable_set("@organisation", @organisation)
    @iterations.should_receive(:active).and_return(@active_iterations)
    controller.send(:get_active_iterations)
    controller.instance_variable_get("@active_iterations").should ==
      @active_iterations
  end

  describe "show" do
    def do_call
      get :show
    end

    before :each do
      controller.instance_variable_set("@organisation", @organisation)
    end

    it_should_behave_like "it's successful"
    
    it "should assign organisation" do
      controller.should_receive(:get_organisation)
      do_call
    end

    it "should assign active iterations" do
      controller.should_receive(:get_active_iterations)
      do_call
    end
  end

end
