require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoryTeamMembersController do

  before :each do
    login
    @user = Users.create_user
    controller.stub!(:current_user).and_return(@user)
    @project = Projects.create_project
    @iteration = Iterations.create_iteration :project => @project
    @story = Stories.create_story(:project => @project,
                                  :iteration => @iteration)
  end

  describe "create" do
    def do_call
      post :create, :story_team_member => {
        :story_id => @story.id
      }
    end

    describe "success" do
      it "should assign the story to the user" do
        do_call
        @user.reload
        @user.stories.should include(@story)
      end

      it "should redirect to the iteration story page" do
        do_call
        response.should redirect_to(project_iteration_story_url(@project, 
                                                                @iteration, 
                                                                @story))
      end
    end

    describe "failure" do
      before :each do
        @story = Stories.create_story(:project => @project)
        StoryTeamMember.create!(:user => @user, :story => @story)
      end

      it "should re-render the story page" do
        do_call
        response.should render_template('stories/show')
      end

      it "should assign the story" do
        do_call
        assigns[:story].should == @story
      end

      it "should assign the story team member" do
        do_call
        assigns[:story_team_member].should_not be_nil
      end
    end
  end

  describe "destroy" do
    def do_call
      delete :destroy, :id => @story_team_member.id
    end

    before :each do
      @story_team_member = 
        StoryTeamMembers.create_story_team_member!(:story => @story)
    end

    it "should delete" do
      do_call
      StoryTeamMember.should_not be_exist(@story_team_member.id)
    end

    it "should redirect to the story page" do
      do_call
      response.should redirect_to(project_iteration_story_url(@project, 
                                                              @iteration,
                                                              @story))
    end
  end

end
