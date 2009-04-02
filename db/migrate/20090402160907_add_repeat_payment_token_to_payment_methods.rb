class AddRepeatPaymentTokenToPaymentMethods < ActiveRecord::Migration
  def self.up
    add_column :payment_methods, :repeat_payment_token, :text
  end

  def self.down
    remove_column :payment_methods, :repeat_payment_token
  end
end
