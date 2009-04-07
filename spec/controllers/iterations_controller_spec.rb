require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IterationsController do
  before :each do
    login
    setup_project
    setup_iteration
  end

  describe "it operates on a new iteration", :shared => true do
    it "should assign a new iteration" do
      do_call
      assigns[:iteration].should be_kind_of(Iteration)
    end
  end

  describe "index" do
    def do_call
      get :index
    end
    
    before :each do
      @active_iterations = []
      Project.delete_all
      Iteration.delete_all
      Story.delete_all
      2.times do
        project = Projects.create_project!(:organisation => @organisation)
        story = Stories.create_story!(:project => project)
        iteration = Iterations.create_iteration!(
          :project => project,
          :stories => [story]
        )

        iteration.start

        @active_iterations << iteration
      end

      # Create some pending iterations too
      2.times do
        story = Stories.create_story!(:project => @project)
        Iterations.create_iteration!(
          :project => @project,
          :stories => [story]
        )
      end
    end

    it_should_behave_like "it's successful"

    it "should assign all of the active iterations for the organisation" do
      do_call
      assigns[:iterations].size.should == @active_iterations.size
      @active_iterations.each do |iteration|
        assigns[:iterations].should include(iteration)
      end
    end
  end

  describe "finshed" do
    def do_call
      get :finished
    end

    before :each do
      @finished_iterations = []
      project = Projects.create_project!(:organisation => @organisation)
      Iteration.delete_all

      3.times do
        story = Stories.create_story!(:project => @project)
        iteration = Iterations.create_iteration!(
          :project => project,
          :stories => [story],
          :end_date => 3.days.ago
        )
        @finished_iterations << iteration
      end

      # Create some active and pending iterations too
      2.times do
        story = Stories.create_story!(:project => @project)
        Iterations.create_iteration!(
          :project => @project,
          :stories => [story]
        ).start
      end

      2.times do
        story = Stories.create_story!(:project => @project)
        Iterations.create_iteration!(
          :project => @project,
          :stories => [story]
        )
      end
    end

    it_should_behave_like "it's successful"
    
    it "should assign all of the finished iterations for the organisation" do
      do_call
      assigns[:iterations].sort.should == @finished_iterations.sort
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
