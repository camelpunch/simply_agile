class AddStatusToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :status, :string, :default => 'pending'
  end

  def self.down
    remove_column :stories, :status
  end
end
