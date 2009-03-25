class StoryTeamMember < ActiveRecord::Base
  attr_protected :user_id
  belongs_to :user
  belongs_to :story

  validates_presence_of :user_id, :story_id

  validates_uniqueness_of :story_id, :scope => :user_id,
    :message => 'is already assigned to you'
end
