require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoriesController do

  before :each do
    login
    stub_projects!

    @iteration = mock_model Iteration
    @story = mock_model Story
    @new_story = mock_model Story, :content= => '', :iteration_id? => false
    @stories = mock('Collection', :build => @new_story, :find => @story)
    @iteration_stories = mock('Collection', :build => @new_story, :find => @story)
    @iterations = mock('Collection', :find => @iteration)
    @project.stub!(:iterations).and_return(@iterations)
    @project.stub!(:stories).and_return(@stories)
    @iteration.stub!(:stories).and_return(@iteration_stories)
  end

  describe "instance variable setup" do
    before :each do
      controller.instance_variable_set('@project', @project)
    end

    describe "new_story" do
      describe "with iteration" do
        before :each do
          controller.stub!(:params).and_return(:iteration_id => @iteration.id,
                                               :project_id => @project.id)
          controller.instance_variable_set('@iteration', @iteration)
        end

        it "should set the iteration" do
          @iteration_stories.should_receive(:build)
          controller.send(:new_story)
        end
      end

      describe "with project" do
        before :each do
          controller.stub!(:params).and_return(:project_id => @project.id)
        end

        it "should set the project" do
          @stories.should_receive(:build)
          controller.send(:new_story)
        end

        it "should set the instance variable" do
          controller.send(:new_story)
          controller.instance_variable_get("@story").should == @new_story
        end
      end

      describe "without project" do
        before :each do
          controller.instance_variable_set('@project', nil)
        end

        it "should set the instance variable" do
          new_story_without_project = Story.new
          Story.stub!(:new).and_return(new_story_without_project)
          controller.send(:new_story)
          controller.instance_variable_get('@story').should == new_story_without_project
        end
      end
    end

    describe "get_iteration" do
      before :each do
        controller.stub!(:params).and_return(
          :project_id => @project.id,
          :iteration_id => @iteration.id
        )
      end

      it "should get the iteration from the project" do
        @iterations.should_receive(:find).with(@iteration.id)
        controller.send(:get_iteration)
      end

      it "should set the instance variable" do
        controller.send(:get_iteration)
        controller.instance_variable_get('@iteration').should == @iteration
      end
    end

    describe "get_story" do
      before :each do
        controller.stub!(:params).and_return(
          :project_id => @project.id,
          :id => @story.id
        )
      end

      it "should get the story from the project" do
        @stories.should_receive(:find).with(@story.id)
        controller.send(:get_story)
      end

      it "should set the instance variable" do
        controller.send(:get_story)
        controller.instance_variable_get("@story").should == @story
      end
    end

    describe "get_story_from_iteration" do
      before :each do
        controller.stub!(:params).and_return(
          :project_id => @project.id,
          :iteration_id => @iteration.id,
          :id => @story.id
        )
        controller.instance_variable_set('@project', @project)
      end

      it "should get the story from the iteration" do
        @stories.should_receive(:find).
          with(@story.id, :conditions => ['iteration_id = ?', @iteration.id])
        controller.send(:get_story_from_iteration)
      end

      it "should set the instance variable" do
        controller.send(:get_story_from_iteration)
        controller.instance_variable_get("@story").should == @story
      end
    end
  end

  describe "it operates on a new story", :shared => true do
    it "should call new_story" do
      controller.should_receive(:new_story)
      do_call
    end
  end

  describe "it operates on an existing story", :shared => true do
    it "should call get_story" do
      controller.should_receive(:get_story)
      do_call
    end
  end

  describe "it operates on an existing story from an iteration", :shared => true do
    it "should call get_story_from_iteration" do
      controller.should_receive(:get_story_from_iteration)
      do_call
    end
  end

  describe "backlog" do
    def do_call
      get :backlog, :project_id => @project.id
    end

    before :each do
      controller.stub!(:get_project)
      controller.instance_variable_set("@project", @project)
      @stories.stub!(:backlog).and_return(mock('Collection', :empty? => false))
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it's successful"

    describe "with backlog" do
      before :each do
        @stories.stub!(:backlog).
          and_return(mock('Collection', :empty? => false))
      end

      it "should render backlog template" do
        do_call
        response.should render_template('stories/backlog')
      end
    end

    describe "with no backlog" do
      before :each do
        @stories.stub!(:backlog).
          and_return(mock('Collection', :empty? => true))
      end

      it "should render backlog_guidance template" do
        do_call
        response.should render_template('stories/backlog_guidance')
      end
    end
  end

  describe "index" do
    def do_call
      get :index, :project_id => @project.id
    end

    before :each do
      controller.stub!(:get_project)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it's successful"
  end

  describe "new" do
    def do_call
      get :new, :project_id => @project.id
    end

    before :each do
      controller.stub!(:get_project)
      controller.stub!(:new_story)
      controller.instance_variable_set('@story', @new_story)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on a new story"
    it_should_behave_like "it's successful"

    describe "with iteration" do
      def do_call
        get :new, :project_id => @project.id, :iteration_id => @iteration.id
      end

      before :each do
        controller.instance_variable_set('@iteration', @iteration)
      end

      it_should_behave_like "it belongs to an iteration"
      it_should_behave_like "it operates on a new story"
      it "should render the with_iteration template" do
        do_call
        response.should render_template('stories/new_with_iteration')
      end
    end

    describe "with project" do
      before :each do
        controller.instance_variable_set('@project', @project)
      end

      it "should render the with_project template" do
        do_call
        response.should render_template('stories/new_with_project')
      end
    end

    it "should set a default story" do
      @new_story.should_receive(:content=)
      do_call
    end

    describe "without project" do
      before :each do
        controller.instance_variable_set('@project', nil)
      end

      describe "when there are projects" do
        it "should render the new_without_project template" do
          do_call
          response.should render_template('stories/new_without_project')
        end
      end

      describe "when there are no projects" do
        before :each do
          @projects.stub!(:empty?).and_return(true)
        end

        it "should render the new_guidance template" do
          do_call
          response.should render_template('stories/new_guidance')
        end
      end
    end
  end

  describe "create" do
    def do_call(params = {})
      post(:create, 
           {:project_id => @project.id, :story => @attributes}.
           merge(params))
    end

    before :each do
      controller.stub!(:get_project)
      controller.stub!(:new_story)

      controller.instance_variable_set('@project', @project)
      controller.instance_variable_set('@story', @new_story)

      @attributes = {
        'name' => 'User can log in',
        'content' => 'As a user I want to log in so that I can do stuff',
      }

      @new_story.stub!(:save)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on a new story"

    it "should attempt to save" do
      @new_story.should_receive(:save)
      do_call
    end

    describe "success" do
      before :each do
        @new_story.stub!(:save).and_return(true)
      end

      describe "html" do
        it "should redirect to show" do
          do_call
          response.should redirect_to(project_story_url(@project, @new_story))
        end

        it "should provide a flash notice" do
          do_call
          flash[:notice].should_not be_blank
        end
      end

      describe "js" do
        it "should render created code" do
          do_call :format => 'js'
          response.code.should == '201'
        end

        it "should provide the location" do
          do_call :format => 'js'
          response.location.should == project_story_url(@project, @new_story)
        end
      end
    end

    describe "failure" do
      before :each do
        @new_story.stub!(:save).and_return(false)
      end

      it "should call render with the 422 status code" do
        controller.should_receive(:render).with(hash_including(:status => :unprocessable_entity))
        do_call
      end

      describe "with no iteration" do
        it "should re-render the new_with_project template" do
          do_call
          response.should render_template('stories/new_with_project')
        end
      end

      describe "with iteration" do
        before :each do
          @new_story.stub!(:iteration_id?).and_return(true)
          @new_story.stub!(:iteration).
            and_return(@specific_iteration = mock_model(Iteration))
        end

        it "should re-render the new_with_iteration template" do
          do_call
          response.should render_template('stories/new_with_iteration')
        end

        it "should assign the iteration from the object's iteration" do
          do_call
          assigns[:iteration].should == @specific_iteration
        end
      end
    end
  end

  describe "show" do
    def do_call
      get :show, :id => @story.id, :project_id => @project.id
    end

    before :each do
      controller.stub!(:get_story)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on an existing story"
    it_should_behave_like "it's successful"
  end

  describe "estimate" do
    def do_call
      get :estimate, :id => @story.id, :project_id => @project.id
    end

    before :each do
      controller.stub!(:get_story)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on an existing story"
    it_should_behave_like "it's successful"

    it "should render the estimate template" do
      do_call
      response.should render_template('stories/estimate')
    end
  end

  describe "edit" do
    def do_call
      get :edit, :id => @story.id, :project_id => @project.id
    end

    before :each do
      controller.stub!(:get_story)
      controller.instance_variable_set('@project', @project)
      controller.instance_variable_set('@story', @story)
      @story.stub!(:iteration_id).and_return(@iteration.id)
      @story.stub!(:iteration_id?).and_return(false)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on an existing story"

    describe "when iteration set on story" do
      before :each do
        @story.stub!(:iteration_id?).and_return(true)
      end

      it "should redirect to the iteration route" do
        do_call
        response.should redirect_to(edit_project_iteration_story_url(@project, @iteration, @story))
      end
    end

    describe "with iteration id params" do
      def do_call
        get :edit, :id => @story.id,
          :project_id => @project.id,
          :iteration_id => @iteration.id
      end

      it_should_behave_like "it operates on an existing story from an iteration"
    end
  end

  describe "update" do

    before :each do
      @story.stub!(:update_attributes!)
      @story.errors.stub!(:full_messages).and_return([''])
    end

    describe "it attempts to update", :shared => true do
      it "should attempt to save" do
        @story.should_receive(:update_attributes!).with(@story_attributes)
        do_call
      end
    end

    describe "it has the standard story failure mode", :shared => true do
      before :each do
        @story.stub!(:update_attributes!).and_raise(ActiveRecord::RecordInvalid.new(@story))
      end

      it "should re-render the edit page" do
        do_call
        response.should render_template('stories/edit')
      end
    end

    describe "without iteration id" do
      def do_call
        put(:update, 
            {:id => @story.id, 
            :project_id => @project.id,
            :story => @story_attributes})
      end

      before :each do
        controller.stub!(:get_story)
        controller.instance_variable_set('@project', @project)
        controller.instance_variable_set('@story', @story)
        @story_attributes = { 'name' => 'some new name' }
      end

      it_should_behave_like "it belongs to a project"
      it_should_behave_like "it operates on an existing story"
      it_should_behave_like "it attempts to update"

      describe "success" do
        before :each do
          @story.stub!(:update_attributes!).and_return(true)
        end

        it "should redirect to project story url" do
          do_call
          response.should redirect_to(project_story_url(@project, @story))
        end
      end

      it_should_behave_like "it has the standard story failure mode"
    end

    describe "with iteration id" do
      def do_call(params = {})
        put(:update, 
            {:id => @story.id, 
            :project_id => @project.id,
            :iteration_id => @iteration.id,
            :story => @story_attributes}.merge(params))
      end

      before :each do
        controller.stub!(:get_story)
        controller.instance_variable_set('@project', @project)
        controller.instance_variable_set('@story', @story)
      end

      describe "status update" do
        before :each do
          @story_attributes = { 'status' => 'testing' }
        end

        it_should_behave_like "it attempts to update"
        it_should_behave_like "it operates on an existing story from an iteration"

        describe "success" do
          before :each do
            @story.stub!(:update_attributes!).and_return(true)
          end

          describe "html" do
            it "should redirect to project iteration url" do
              do_call :story => {'status' => 'testing'}
              response.should redirect_to(project_iteration_url(@project,
                                                                @iteration))
            end
          end

          describe "js" do
            it "should be successful" do
              do_call(:format => 'js')
              response.should be_success
            end
          end
        end

        it_should_behave_like "it has the standard story failure mode"
      end

      describe "non-status update" do
        before :each do
          @story_attributes = { 'name' => 'some story name' }
        end

        it_should_behave_like "it operates on an existing story from an iteration"
        it_should_behave_like "it attempts to update"

        describe "success" do
          before :each do
            @story.stub!(:update_attributes!).and_return(true)
          end

          describe "html" do
            it "should redirect to project iteration story page" do
              do_call
              response.should redirect_to(project_iteration_story_url(@project,
                                                                      @iteration,
                                                                      @story))
            end
          end
        end

        it_should_behave_like "it has the standard story failure mode"
      end
    end
  end
end
