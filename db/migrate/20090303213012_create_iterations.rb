class CreateIterations < ActiveRecord::Migration
  def self.up
    create_table :iterations do |t|
      t.integer :project_id
      t.string :name
      t.integer :duration
      t.date :started_on
      t.date :finished_on

      t.timestamps
    end
  end

  def self.down
    drop_table :iterations
  end
end
