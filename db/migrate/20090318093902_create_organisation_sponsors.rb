class CreateOrganisationSponsors < ActiveRecord::Migration
  def self.up
    create_table :organisation_sponsors do |t|
      t.integer :user_id
      t.integer :sponsor_id
      t.integer :organisation_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organisation_sponsors
  end
end
