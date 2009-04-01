class AddSuspendedToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :suspended, :boolean
  end

  def self.down
    remove_column :organisations, :suspended
  end
end
