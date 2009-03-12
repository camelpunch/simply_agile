class RemoveStartedOnAndFinishedOnFromIteration < ActiveRecord::Migration
  def self.up
    remove_column :iterations, :started_on
    remove_column :iterations, :finished_on
  end

  def self.down
    add_column :iterations, :started_on, :date
    add_column :iterations, :finished_on, :date
  end
end
