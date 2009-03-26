class DeleteOrganisationSponsors < ActiveRecord::Migration
  def self.up
    drop_table :organisation_sponsors
  end

  def self.down
    create_table :organisation_sponsors do |t|
      t.integer :user_id
      t.integer :sponsor_id
      t.integer :organisation_id

      t.timestamps
    end
  end
end
