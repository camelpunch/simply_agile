class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.integer :project_id
      t.integer :iteration_id
      t.string :name
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end
end
