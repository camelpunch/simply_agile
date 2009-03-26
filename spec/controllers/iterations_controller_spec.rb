require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IterationsController do
  def mock_story
    mock_model(Story, 
      :estimate= => nil,
      :save! => true,
      :iteration= => nil,
      :attributes= => nil,
      :update_attributes! => nil)
  end

  before :each do
    login
    setup_project
    setup_iteration
  end

  describe "instance variable setup" do
    before :each do
      controller.instance_variable_set('@project', @project)
    end

    describe "get_iteration" do
      before :each do
        controller.stub!(:params).and_return(
          :project_id => @project.id,
          :id => @iteration.id
        )
      end

      def iteration
        controller.instance_variable_get("@iteration")
      end

      it "should get the iteration from the project" do
        controller.send(:get_iteration)
        iteration.project.should == @project
      end

      it "should set the instance variable" do
        controller.send(:get_iteration)
        @iteration.should == @iteration
      end
    end

    describe "get_stories" do
      it "should get the assigned or available stories for the iteration" do
        controller.instance_variable_set("@iteration", @iteration)
        controller.send(:get_stories)
        controller.instance_variable_get("@stories").should == [@story]
      end
    end

    describe "new_iteration" do
      before :each do
        controller.stub!(:params).and_return({})
      end

      def iteration
        controller.instance_variable_get("@iteration")
      end

      it "should set the project" do
        controller.send(:new_iteration)
        iteration.project.should == @project
      end

      it "should set the instance variable" do
        controller.send(:new_iteration)
        iteration.should be_kind_of(Iteration)
      end
    end
  end

  describe "it operates on a new iteration", :shared => true do
    it "should assign a new iteration" do
      do_call
      assigns[:iteration].should be_kind_of(Iteration)
    end
  end

  describe "new" do
    def do_call
      get :new, :project_id => @project.id
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on a new iteration"
    it_should_behave_like "it's successful"

    it "should assign stories" do
      @available_story = Stories.create_story!(:project => @project)
      do_call
      assigns[:stories].should == [@available_story]
    end

    describe "when there are no stories" do
      it "should render the guidance template" do
        controller.instance_variable_set('@stories', [])
        do_call
        response.should render_template('iterations/new_guidance')
      end
    end
  end

  describe "create" do
    def do_call
      post :create, :project_id => @project.id, :iteration => @attributes,
        :stories => @stories_attributes
    end

    before :each do
      @attributes = { 'name' => 'iteration 1', :duration => '7' }
      @stories_attributes = {
        @story.id.to_s => { :estimate => '3', :include => '1' }
      }
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on a new iteration"

    describe "success" do
      it "should redirect to iterations/show" do
        do_call
        response.should redirect_to(project_iteration_url(@project, 
            assigns[:iteration]))
      end
    end

    describe "failure" do
      before :each do
        @stories_attributes = {}
      end
      
      it "should re-render new template" do
        do_call
        response.should render_template('iterations/new')
      end

      it "should reassign planned stories" do
        do_call
        assigns[:stories].should == []
      end
    end
  end

  describe "an existing iteration action", :shared => true do
    it_should_behave_like "it belongs to a project"

    it "should assign the iteration" do
      do_call
      assigns[:iteration].should == @iteration
    end
  end

  describe "show" do
    def do_call
      get :show, :id => @iteration.id, :project_id => @project.id
    end

    before :each do
      @iteration.start
    end

    it_should_behave_like "an existing iteration action"
    it_should_behave_like "it's successful"

    it "should render the show template if the iteration is not active" do
      do_call
      response.should render_template('iterations/show')
    end

    it "should render the show_active template if iteration is active" do
      do_call
      response.should render_template('iterations/show_active')
    end
  end

  describe "edit" do
    def do_call
      get :edit, :id => @iteration.id, :project_id => @project.id
    end

    it "should assign stories" do
      controller.should_receive(:get_stories)
      do_call
    end

    it_should_behave_like "an existing iteration action"
    it_should_behave_like "it's successful"
  end

  describe "update" do
    def do_call
      put :update, :id => @iteration.id, :project_id => @project.id,
        :iteration => @attributes,
        :stories => @stories_attributes
    end

    before :each do
      @attributes = {:duration => '31'}
      @stories_attributes = {
        @story.id.to_s => { 'estimate' => '3', 'include' => '1' }
      }
    end

    it_should_behave_like "an existing iteration action"

    it "should update iteration attributes" do
      @iteration.should be_valid
      do_call
      @iteration.reload
      @iteration.duration.should == 31
    end

    describe "success" do
      it "should redirect to iterations/show" do
        do_call
        response.should redirect_to(project_iteration_url(@project, 
            @iteration))
      end
    end

    describe "failure" do
      before :each do
        @stories_attributes = {}
      end
      
      it "should re-render edit template" do
        do_call
        response.should render_template('iterations/edit')
      end

      it "should reassign planned stories" do
        do_call
        assigns[:stories].should == []
      end
    end
  end
end
