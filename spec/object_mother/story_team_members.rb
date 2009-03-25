class StoryTeamMembers < ObjectMother
  truncate_story_team_member

  def self.story_team_member_prototype
    {
      :user => Users.create_user,
    }
  end

end
