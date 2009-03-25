class CreateStoryTeamMembers < ActiveRecord::Migration
  def self.up
    create_table :story_team_members do |t|
      t.integer :user_id
      t.integer :story_id

      t.timestamps
    end
  end

  def self.down
    drop_table :story_team_members
  end
end
