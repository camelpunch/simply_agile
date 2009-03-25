class AddEndDateToIterations < ActiveRecord::Migration
  def self.up
    add_column :iterations, :end_date, :date
  end

  def self.down
    remove_column :iterations, :end_date
  end
end
