class CreateBurndownDataPoints < ActiveRecord::Migration
  def self.up
    create_table :burndown_data_points do |t|
      t.integer :iteration_id
      t.integer :story_points
      t.date :date
    end
  end

  def self.down
    drop_table :burndown_data_points
  end
end
