require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IterationsController do
  def mock_story
    mock_model(Story, 
               :estimate= => nil, 
               :save! => true, 
               :iteration= => nil)
  end

  before :each do
    login
    stub_projects!

    @iteration = mock_model Iteration, :stories => []
    @new_iteration = mock_model Iteration, :stories => []

    @iterations = mock('Collection',
                       :find => @iteration,
                       :build => @new_iteration)

    @project.stub!(:iterations).and_return(@iterations)
    @project.stub!(:stories).and_return([mock_model(Story)])

    @story_1 = mock_story
    @story_2 = mock_story
    @story_3 = mock_story

    @stories = [@story_1, @story_2]
    @story_1_attributes = {'include' => '1', 'estimate' => '5'}
    @story_2_attributes = {'include' => '0', 'estimate' => ''}
    @story_3_attributes = {'include' => '1', 'estimate' => '6'}
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

      it "should get the iteration from the project" do
        @iterations.should_receive(:find).with(@iteration.id)
        controller.send(:get_iteration)
      end

      it "should set the instance variable" do
        controller.send(:get_iteration)
        controller.instance_variable_get("@iteration").should == @iteration
      end
    end

    describe "new_iteration" do
      before :each do
        controller.stub!(:params).and_return({})
      end

      it "should set the project" do
        @iterations.should_receive(:build)
        controller.send(:new_iteration)
      end

      it "should set the instance variable" do
        controller.send(:new_iteration)
        controller.instance_variable_get("@iteration").should == @new_iteration
      end
    end
  end

  describe "it operates on a new iteration", :shared => true do
    it "should call new_iteration" do
      controller.should_receive(:new_iteration)
      do_call
    end
  end

  describe "new" do
    def do_call
      get :new, :project_id => @project.id
    end

    before :each do
      controller.stub!(:get_project)
      controller.stub!(:new_iteration)
      controller.instance_variable_set('@project', @project)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on a new iteration"
    it_should_behave_like "it's successful"

    it "should assign the new iteration" do
      controller.should_receive(:new_iteration)
      do_call
    end

    describe "when there are no project stories" do
      before :each do
        @project.stub!(:stories).and_return([])
      end

      it "should redirect to stories/new" do
        do_call
        response.should redirect_to(new_project_story_url(@project))
      end

      it "should provide a flash notice" do
        do_call
        flash[:notice].should_not be_blank
      end
    end
  end

  describe "create" do
    def do_call
      post :create, :project_id => @project.id, :iteration => @attributes,
        :stories => {
          @story_1.id.to_s => @story_1_attributes,
          @story_2.id.to_s => @story_2_attributes,
        }
    end

    before :each do
      @project.stub!(:stories).and_return(@stories)
      controller.instance_variable_set('@project', @project)
      controller.instance_variable_set('@iteration', @new_iteration)
      @new_iteration.stub!(:save!)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on a new iteration"

    it "should attempt to save" do
      @new_iteration.should_receive(:save!)
      do_call
    end

    describe "story handling" do
      after :each do
        do_call
      end

      it "should find all the stories" do
        @project.should_receive(:stories)
      end

      it "should set the stories' attributes" do
        @story_1.should_receive(:estimate=).with('5')
        @story_2.should_receive(:estimate=).with('')
      end

      it "should assign stories to the iteration" do
        @new_iteration.stories.should_receive('<<').with(@story_1)
      end

      it "should not assign stories with include 0" do
        @new_iteration.stories.should_not_receive('<<').with(@story_2)
      end

      it "should save stories not assigned to the iteration" do
        @story_2.should_receive(:save!)
      end

      it "should not save explicitly stories assign to the iteration" do
        @story_1.should_not_receive(:save!)
      end
    end

    describe "success" do
      before :each do
        @new_iteration.stub!(:save!).and_return(true)
      end

      it "should provide a flash notice" do
        do_call
        flash[:notice].should_not be_blank
      end

      it "should redirect to iterations/show" do
        do_call
        response.should redirect_to(project_iteration_url(@project, 
                                                          @new_iteration))
      end
    end

    describe "failure" do
      before :each do
        @new_iteration.errors.stub!(:full_messages).and_return([''])
        @new_iteration.stub!(:save!).
          and_raise(ActiveRecord::RecordInvalid.new(@new_iteration))
      end

      it "should re-render new template" do
        do_call
        response.should render_template('iterations/new')
      end
    end
  end

  describe "an existing iteration action", :shared => true do
    before :each do
      controller.stub!(:get_iteration)
    end

    it_should_behave_like "it belongs to a project"

    it "should assign the iteration" do
      controller.should_receive(:get_iteration)
      do_call
    end
  end

  describe "show" do
    def do_call
      get :show, :id => @iteration.id, :project_id => @project.id
    end

    it_should_behave_like "an existing iteration action"
    it_should_behave_like "it's successful"
  end

  describe "edit" do
    def do_call
      get :edit, :id => @iteration.id, :project_id => @project.id
    end

    it_should_behave_like "an existing iteration action"
    it_should_behave_like "it's successful"
  end

  describe "update" do
    def do_call
      put :update, :id => @iteration.id, :project_id => @project.id,
        :stories => {
          @story_1.id.to_s => @story_1_attributes,
          @story_2.id.to_s => @story_2_attributes,
          @story_3.id.to_s => @story_3_attributes,
        }
    end

    before :each do
      @project.stub!(:stories).and_return(@stories + [@story_3])
      controller.instance_variable_set('@project', @project)
      controller.instance_variable_set('@iteration', @iteration)
      @iteration.stub!(:stories).and_return([@story_2, @story_3])
      @iteration.stub!(:save!)
    end

    it_should_behave_like "an existing iteration action"

    it "should attempt to save" do
      @iteration.should_receive(:save!)
      do_call
    end

    describe "story handling" do
      after :each do
        do_call
      end

      it "should find all the stories" do
        @project.should_receive(:stories)
      end

      it "should set the stories' attributes" do
        @story_1.should_receive(:estimate=).with('5')
        @story_2.should_receive(:estimate=).with('')
        @story_3.should_receive(:estimate=).with('6')
      end

      it "should assign stories to the iteration" do
        @iteration.stories.should_receive('<<').with(@story_1)
      end

      it "should not assign stories already assigned" do
        @iteration.stories.should_not_receive('<<').with(@story_3)
      end

      it "should unassign stories with include 0" do
        @iteration.stories.should_receive(:delete).with(@story_2)
      end

      it "should save stories unassigned from the iteration" do
        @story_2.should_receive(:save!)
      end

      it "should not save explicitly stories assigned to the iteration" do
        @story_1.should_not_receive(:save!)
      end
    end

    describe "success" do
      before :each do
        @iteration.stub!(:save!).and_return(true)
      end

      it "should provide a flash notice" do
        do_call
        flash[:notice].should_not be_blank
      end

      it "should redirect to iterations/show" do
        do_call
        response.should redirect_to(project_iteration_url(@project, 
                                                          @iteration))
      end
    end

    describe "failure" do
      before :each do
        @iteration.errors.stub!(:full_messages).and_return([''])
        @iteration.stub!(:save!).
          and_raise(ActiveRecord::RecordInvalid.new(@iteration))
      end

      it "should re-render edit template" do
        do_call
        response.should render_template('iterations/edit')
      end
    end
  end
end
