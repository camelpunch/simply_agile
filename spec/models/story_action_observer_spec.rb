require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoryActionObserver do
  before :each do
    @user = Users.create_user!
    @project = Projects.create_project!(:organisation => @user.organisations.first)
    @story = Stories.create_story!(:project => @project)
    @iteration = Iterations.create_iteration!(
      :stories => [@story],
      :project => @project
    )
    @story.update_attribute(:iteration_id, @iteration.id)
  end

  describe "it creates a story action", :shared => true do
    it "should be created" do
      story_action_count = StoryAction.count
      do_action
      StoryAction.count.should == story_action_count + 1
    end

    it "should set the user" do
      do_action
      story_action = StoryAction.find(:last, :order => 'id')
      story_action.user.should == @user
    end

    it "should set the story" do
      do_action
      story_action = StoryAction.find(:last, :order => 'id')
      story_action.story.should == @story
    end

    it "should set the iteration" do
      do_action
      story_action = StoryAction.find(:last, :order => 'id')
      story_action.iteration.should == @iteration
    end
  end

  describe "it does not create a story action", :shared => true do
    it "should not be created" do
      story_action_count = StoryAction.count
      do_action
      StoryAction.count.should == story_action_count
    end
  end

  describe "joining a story team" do
    def do_action
      StoryTeamMember.with_observers(:story_action_observer) do
        StoryTeamMember.create!(
          :user => @user,
          :story => @story,
          :current_user => @user
        )
      end
    end

    it_should_behave_like "it creates a story action"
  end

  describe "completing an acceptance criterion" do
    def do_action
      @acceptance_criterion = @story.acceptance_criteria.create!(
        :criterion => 'some criterion',
        :current_user => @user
      )
      AcceptanceCriterion.with_observers(:story_action_observer) do
        @acceptance_criterion.update_attributes!(:fulfilled_at => Time.now)
      end
    end

    it_should_behave_like "it creates a story action"

    it "should not barf if story isn't in an iteration" do
      $debug = 1
      @story.update_attribute(:iteration_id, nil)
      do_action
    end
  end
  
  describe "changing acceptance criteria details" do
    def do_action
      @acceptance_criterion = @story.acceptance_criteria.create!(
        :criterion => 'some criterion',
        :current_user => @user
      )
      AcceptanceCriterion.with_observers(:story_action_observer) do
        @acceptance_criterion.update_attributes!(:criterion => "new criterion")
      end
    end

    it_should_behave_like "it does not create a story action"
  end

  describe "changing story status" do
    def do_action
      @story.current_user = @user
      Story.with_observers(:story_action_observer) do
        @story.update_attributes!(:status => "complete")
      end
    end

    it_should_behave_like "it creates a story action"
  end

  describe "changing story attributes" do
    def do_action
      @story.current_user = @user
      Story.with_observers(:story_action_observer) do
        @story.update_attributes!(:content => "new content")
      end
    end

    it_should_behave_like "it does not create a story action"
  end

  describe "duplicate entries" do
    it "should not be created" do
      @story.current_user = @user
      Story.with_observers(:story_action_observer) do
        @story.update_attributes!(:status => "complete")
        @story.update_attributes!(:status => "testing")
      end

      StoryAction.count(:conditions => { :user_id => @user.id }).should == 1
    end
  end
end
