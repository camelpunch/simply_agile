class CreateStoryActions < ActiveRecord::Migration
  def self.up
    create_table :story_actions do |t|
      t.integer :user_id
      t.integer :story_id
      t.integer :iteration_id

      t.timestamps
    end
  end

  def self.down
    drop_table :story_actions
  end
end
