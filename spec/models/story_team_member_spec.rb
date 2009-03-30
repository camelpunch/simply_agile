require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoryTeamMember do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :story_id => 1
    }
  end
  
  it "should have a current user" do
    StoryTeamMember.ancestors.should include(CurrentUser)
  end

  describe "protection" do
    it "should not allow mass-assignment of user_id" do
      member = StoryTeamMember.new :user_id => 22
      member.user_id.should be_blank
    end
  end

  describe "associations" do
    it "should belong to a user" do
      StoryTeamMember.should belong_to(:user)
    end

    it "should belong to a story" do
      StoryTeamMember.should belong_to(:story)
    end
  end

  describe "validations" do
    before :each do
      @story_team_member = StoryTeamMember.new
      @story_team_member.valid?

      @project = Projects.create_project
      @organisation1 = Organisations.create_organisation
      @organisation1.projects = [@project]
      @organisation2 = Organisations.create_organisation
      @user = Users.create_user :organisations => [@organisation2]
      @story = Stories.create_story :project => @project
    end

    it "should require a user" do
      @story_team_member.should have(1).error_on(:user_id)
    end

    it "should require a story" do
      @story_team_member.should have(1).error_on(:story_id)
    end

    it "should require that story and user are a unique combination" do
      @user.organisations << @organisation1
      @story_team_member.user = @user
      @story_team_member.story = @story
      @story_team_member.save!
      lambda {StoryTeamMember.create!(:user => @user, :story => @story)}.
        should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should require that user belongs to organisation of story's project" do
      @story_team_member.user = @user
      @story_team_member.story = @story
      @story_team_member.valid?
      @story_team_member.should have(1).error_on(:story)
    end
  end
end
