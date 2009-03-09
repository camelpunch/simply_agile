class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email_address
      t.string :encrypted_password
      t.integer :organisation_id

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
