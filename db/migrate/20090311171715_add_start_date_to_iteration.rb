class AddStartDateToIteration < ActiveRecord::Migration
  def self.up
    add_column :iterations, :start_date, :date
  end

  def self.down
    remove_column :iterations, :start_date
  end
end
