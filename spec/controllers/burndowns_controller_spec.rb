require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BurndownsController do
  before :each do
    login
    @iteration = mock_model Iteration
  end

  describe "instance variable setup" do
    before :each do
      controller.instance_variable_set("@iteration", @iteration)
    end

    describe "get_burndown" do
      before :each do
        @iteration.stub!(:burndown)
      end
      
      it "should get the burndown from the iteration" do
        @iteration.should_receive(:burndown)
        controller.send(:get_burndown)
      end

      it "should set the instance variable" do
        controller.send(:get_burndown)
        controller.instance_variable_get("@burndown").should == @burndown
      end
    end
  end

  describe "show" do
    def do_call
      get :show, :iteration_id => @iteration.id
    end

    before(:each) do
      controller.stub!(:get_burndown)
    end

    it_should_behave_like "it's successful"

    it "should assign the burndown" do
      controller.should_receive(:get_burndown)
      do_call
    end
  end
end
