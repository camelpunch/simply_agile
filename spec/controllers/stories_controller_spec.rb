require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoriesController do

  before :each do
    login
    setup_project

    @story = Stories.create_story!(:project => @project)
    @iteration = Iterations.create_iteration!(
      :project => @project,
      :stories => [@story]
    )
  end

  describe "getting with a nested iteration" do
    before :each do
      get :show, :id => @story.id, :iteration_id => @iteration.id, :project_id => @project.id
    end

    it "should respond with a 301" do
      response.code.should == '301'
    end

    it "should redirect to project-nested url" do
      response.should redirect_to(project_story_url(@project, @story))
    end
  end

  describe "instance variable setup" do
    before :each do
      controller.instance_variable_set('@project', @project)
    end

    describe "new_story" do
      def story
        controller.instance_variable_get('@story')
      end

      describe "with iteration" do
        before :each do
          controller.stub!(:params).and_return(:iteration_id => @iteration.id,
                                               :project_id => @project.id)
          controller.instance_variable_set('@iteration', @iteration)
        end

        it "should set the iteration" do
          controller.send(:new_story)
          story.iteration.should == @iteration
        end
      end

      describe "with project" do
        before :each do
          controller.stub!(:params).and_return(:project_id => @project.id)
        end

        it "should set the project" do
          controller.send(:new_story)
          story.project.should == @project
        end
      end

      describe "without project" do
        before :each do
          controller.instance_variable_set('@project', nil)
        end

        it "should set the instance variable" do
          controller.send(:new_story)
          story.should be_kind_of(Story)
        end
      end
    end

    describe "get_iteration" do
      def iteration
        controller.instance_variable_get('@iteration')
      end

      before :each do
        controller.stub!(:params).and_return(
          :project_id => @project.id,
          :iteration_id => @iteration.id
        )
      end

      it "should set the instance variable" do
        controller.send(:get_iteration)
        iteration.should == @iteration
      end
    end

    describe "get_story" do
      before :each do
        controller.stub!(:params).and_return(
          :project_id => @project.id,
          :id => @story.id
        )
      end

      it "should set the instance variable" do
        controller.send(:get_story)
        controller.instance_variable_get("@story").should == @story
      end
    end
  end

  describe "it operates on a new story", :shared => true do
    it "should assign a new story" do
      do_call
      assigns[:story].should be_kind_of(Story)
    end
  end

  describe "it operates on an existing story", :shared => true do
    it "should call get_story" do
      do_call
      assigns[:story].should == @story
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

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it's successful"

    describe "json" do
      before :each do
        @iteration = Iterations.create_iteration! :project => @project
      end

      def do_call
        get :index, :project_id => @project.id, :iteration_id => @iteration.id,
          :format => 'json'
      end

      it "should be successful" do
        do_call
        response.should be_success
      end

      it "should get the iteration" do
        controller.should_receive(:get_iteration)
        controller.instance_variable_set('@iteration', @iteration)
        do_call
      end
    end
  end

  describe "new" do
    def do_call(options = {})
      if options.has_key?(:project_id)
        project_id = options[:project_id]
      else
        project_id = @project.id
      end
      get :new, :project_id => project_id
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on a new story"
    it_should_behave_like "it's successful"
    it_should_behave_like "it sets the current user"

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
      do_call
      assigns[:story].content.should_not be_blank
    end

    describe "without project" do
      describe "when there are projects" do
        it "should render the new_without_project template" do
          do_call(:project_id => nil)
          response.should render_template('stories/new_without_project')
        end
      end

      describe "when there are no projects" do
        before :each do
          @organisation.projects.destroy_all
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
      @attributes = {
        'name' => 'User can log in',
        'content' => 'As a user I want to log in so that I can do stuff',
      }
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on a new story"
    it_should_behave_like "it sets the current user"

    it "should attempt to save" do
      do_call
      assigns[:story].should_not be_new_record
    end

    describe "success" do
      describe "html" do
        it "should redirect to show" do
          do_call
          response.should redirect_to(project_story_url(@project, assigns[:story]))
        end
      end

      describe "js" do
        it "should render created code" do
          do_call :format => 'js'
          response.code.should == '201'
        end

        it "should provide the location" do
          do_call :format => 'js'
          response.location.should == project_story_url(@project, assigns[:story])
        end
      end
    end

    describe "failure" do
      before :each do
        @attributes['name'] = nil
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
        it "should re-render the new_with_iteration template" do
          do_call(:iteration_id => @iteration.id)
          response.should render_template('stories/new_with_iteration')
        end

        it "should assign the iteration from the object's iteration" do
          do_call(:iteration_id => @iteration.id)
          assigns[:iteration].should == @iteration
        end
      end
    end
  end

  describe "show" do
    def do_call
      get :show, :id => @story.id, :project_id => @project.id
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on an existing story"
    it_should_behave_like "it's successful"
  end

  describe "estimate" do
    def do_call
      get :estimate, :id => @story.id, :project_id => @project.id
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on an existing story"
    it_should_behave_like "it's successful"

    it "should render the story partial" do
      do_call
      response.should render_template('stories/story')
    end

    it "should set up body_classes" do
      do_call
      assigns[:body_classes].should include('iteration_planning')
    end
  end

  describe "edit" do
    def do_call
      get :edit, :id => @story.id, :project_id => @project.id
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on an existing story"
    it_should_behave_like "it sets the current user"
  end

  describe "update" do

    describe "it has the standard story failure mode", :shared => true do
      before :each do
        @story_attributes["name"] = nil
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
        @story_attributes = { 'name' => 'some new name' }
      end

      it_should_behave_like "it belongs to a project"
      it_should_behave_like "it operates on an existing story"

      describe "success" do
        it "should redirect to project story url" do
          @story_attributes[:name] = 'some name'
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

        it_should_behave_like "it operates on an existing story"
        it_should_behave_like "it sets the current user"

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

        it_should_behave_like "it operates on an existing story"

        describe "success" do
          describe "html" do
            it "should redirect to project story page" do
              @story_attributes['name'] = 'some name'
              do_call
              response.should redirect_to(project_story_url(@project, @story))
            end
          end
        end

        it_should_behave_like "it has the standard story failure mode"
      end
    end
  end
end
