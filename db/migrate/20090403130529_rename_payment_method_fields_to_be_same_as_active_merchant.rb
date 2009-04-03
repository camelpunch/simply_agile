class RenamePaymentMethodFieldsToBeSameAsActiveMerchant < ActiveRecord::Migration
  def self.up
    rename_column :payment_methods, :expiry_month, :month
    rename_column :payment_methods, :expiry_year, :year
  end

  def self.down
    rename_column :payment_methods, :year, :expiry_year
    rename_column :payment_methods, :month, :expiry_month
  end
end
