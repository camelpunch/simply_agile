require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  before :each do
    login
    setup_project
  end

  describe "show" do
    def do_call
      get :show
    end

    describe "with no active iterations worked on" do
      it_should_behave_like "it's successful"

      it "should assign all of the organisation's projects" do
        do_call
        assigns(:projects).should == @organisation.projects
      end
      
      it "should render the page for no work" do
        do_call
        response.should render_template("home/show_without_work")
      end
    end

    describe "with active iterations worked on" do
      before :each do
        @project = @organisation.projects.create!(:name => 'active')
        @story = Stories.create_story!(:project => @project)
        @iteration = Iterations.create_iteration!(
          :stories => [@story],
          :project => @project
        )
        @iteration.start

        @user.story_actions.create!(:story => @story, :iteration => @iteration)
        @user.story_team_members.create!(:story => @story)
      end

      it_should_behave_like "it's successful"

      it "should assign all of the active worked on iterations" do
        do_call
        assigns(:active_iterations_worked_on).should == [@iteration]
      end
      
      it "should assign all of the stories assigned to the user" do
        do_call
        assigns(:stories).should == [@story]
      end

      it "should render the standard show page" do
        do_call
        response.should render_template("home/show")
      end
    end
  end

end
