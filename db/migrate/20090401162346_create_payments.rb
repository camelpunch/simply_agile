class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :organisation_id
      t.string :vpstxid
      t.string :security_key
      t.string :tx_auth_no
      t.string :vendor_tx_code
      t.integer :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
