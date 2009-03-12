require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BurndownsController do
  before :each do
    login
    @iteration = mock_model(Iteration, :name => "Iteration")
    controller.instance_variable_set("@iteration", @iteration)
  end

  describe "instance variable setup" do
    before :each do
      controller.instance_variable_set("@iteration", @iteration)
    end

    describe "get iteration" do
      before :each do
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
      @png = mock("png", :size => "100")
      @burndown = mock_model(Burndown, :to_png => @png)
      controller.stub!(:get_iteration)
      controller.stub!(:get_burndown)
      controller.instance_variable_set("@burndown", @burndown)
    end

    it_should_behave_like "it's successful"

    it "should assign the iteration" do
      controller.should_receive(:get_iteration)
      do_call
    end
    
    it "should assign the burndown" do
      controller.should_receive(:get_burndown)
      do_call
    end

    it "should set the content type to PNG" do
      do_call
      response.headers['Content-type'].should == "image/png"
    end

    it "should set the content disposition to inline and the filename" do
      do_call
      filename = "#{@iteration.name} Burndown.png"
      response.headers['Content-disposition'].should == 
        %{inline; filename="#{filename}"}
    end

    it "should render the burndown png" do
      do_call
      response.body.should == @png.to_s
    end
  end
end
