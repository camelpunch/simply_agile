class CreateOrganisations < ActiveRecord::Migration
  def self.up
    create_table :organisations do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :organisations
  end
end
