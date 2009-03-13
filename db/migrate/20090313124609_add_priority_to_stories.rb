class AddPriorityToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :priority, :integer, :default => 1
  end

  def self.down
    remove_column :stories, :priority
  end
end
