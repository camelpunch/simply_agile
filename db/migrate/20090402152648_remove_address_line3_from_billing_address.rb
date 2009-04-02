class RemoveAddressLine3FromBillingAddress < ActiveRecord::Migration
  def self.up
    remove_column(:billing_addresses, :address_line_3)
  end

  def self.down
    add_column(:billing_addresses, :address_line_3, :string)
  end
end
