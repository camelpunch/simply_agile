class StoryTeamMembersController < ApplicationController
  before_filter :new_story_team_member, :only => [:create]
  before_filter :get_story_team_member, :only => [:destroy]
  before_filter :set_current_user_on_resource

  def create
    if @story_team_member.save
      redirect_to [
        @story_team_member.story.project, 
        @story_team_member.story.iteration, 
        @story_team_member.story
      ]
    else
      @story = @story_team_member.story
      render :template => 'stories/show'
    end
  end

  def destroy
    @story_team_member.destroy
    redirect_to [
      @story_team_member.story.project, 
      @story_team_member.story.iteration, 
      @story_team_member.story
    ]
  end

  protected

  def new_story_team_member
    @story_team_member =
      StoryTeamMember.new(params[:story_team_member].
        merge(:user => current_user))

  end

  def get_story_team_member
    @story_team_member =
      StoryTeamMember.find(params[:id],
      :conditions => ['user_id = ?', current_user.id])
  end
end
