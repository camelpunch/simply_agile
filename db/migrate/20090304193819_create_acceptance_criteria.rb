class CreateAcceptanceCriteria < ActiveRecord::Migration
  def self.up
    create_table :acceptance_criteria do |t|
      t.integer :story_id
      t.string :criterion
      t.datetime :fulfilled_at

      t.timestamps
    end
  end

  def self.down
    drop_table :acceptance_criteria
  end
end
