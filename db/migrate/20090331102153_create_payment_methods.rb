class CreatePaymentMethods < ActiveRecord::Migration
  def self.up
    create_table :payment_methods do |t|
      t.integer :last_four_digits
      t.integer :expiry_month
      t.integer :expiry_year
      t.integer :billing_address_id
      t.integer :user_id
      t.integer :organisation_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :payment_methods
  end
end
