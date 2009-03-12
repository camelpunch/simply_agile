class AddInitialEstimateToIteration < ActiveRecord::Migration
  def self.up
    add_column :iterations, :initial_estimate, :integer
  end

  def self.down
    remove_column :iterations, :initial_estimate
  end
end
