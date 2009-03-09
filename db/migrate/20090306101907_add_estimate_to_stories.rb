class AddEstimateToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :estimate, :integer
  end

  def self.down
    remove_column :stories, :estimate
  end
end
