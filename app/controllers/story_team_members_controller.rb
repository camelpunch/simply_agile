class StoryTeamMembersController < ApplicationController

  def create
    @story_team_member = 
      StoryTeamMember.new(params[:story_team_member].
                          merge(:user => current_user))

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
    @story_team_member = 
      StoryTeamMember.find(params[:id],
                           :conditions => ['user_id = ?', current_user.id])
    @story_team_member.destroy
    redirect_to [
      @story_team_member.story.project, 
      @story_team_member.story.iteration, 
      @story_team_member.story
    ]
  end

end
