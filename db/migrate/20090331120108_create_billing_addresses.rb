class CreateBillingAddresses < ActiveRecord::Migration
  def self.up
    create_table :billing_addresses do |t|
      t.string :name
      t.string :address_line_1
      t.string :address_line_2
      t.string :address_line_3
      t.string :county
      t.string :town
      t.string :postcode
      t.string :country
      t.string :telephone_number

      t.timestamps
    end
  end

  def self.down
    drop_table :billing_addresses
  end
end
