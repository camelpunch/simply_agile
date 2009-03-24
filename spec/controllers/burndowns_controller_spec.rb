require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BurndownsController do
  before :each do
    login
    setup_project
    @story = Stories.create_story!(:project => @project)
    @iteration = Iterations.create_iteration!(
      :project => @project,
      :stories => [@story]
    )
    @iteration.start
  end

  describe "instance variable setup" do
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

    describe "get_burndown" do
      before :each do
        controller.instance_variable_set("@iteration", @iteration)
      end
      
      it "should set the instance variable" do
        controller.send(:get_burndown)
        controller.instance_variable_get("@burndown").should be_kind_of(Burndown)
      end

      it "should be the burndown for the iteration" do
        controller.send(:get_burndown)
        controller.instance_variable_get("@burndown").iteration.should == @iteration
      end

      it "should set the burndown width" do
        controller.stub!(:params).and_return({ :width => 300 })
        controller.send(:get_burndown)
        controller.instance_variable_get("@burndown").width.should == 300
      end
    end
  end

  describe "show" do
    def do_call
      get :show, :iteration_id => @iteration.id
    end

    it_should_behave_like "it's successful"

    it "should assign the iteration" do
      do_call
      assigns[:iteration].should == @iteration
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
      Iteration.stub!(:find).and_return(@iteration)
      @png = mock("png", :size => "100")
      @burndown = mock_model(Burndown, :to_png => @png)
      @iteration.stub!(:burndown).and_return(@burndown)

      do_call
      response.body.should == @png.to_s
    end
  end
end
