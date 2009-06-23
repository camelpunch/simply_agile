class ReplaceRepeatPaymentTokenWithInitialPaymentInPaymentMethods < ActiveRecord::Migration
  def self.up
    remove_column :payment_methods, :repeat_payment_token
    add_column :payment_methods, :initial_payment_id, :integer
  end

  def self.down
    add_column :payment_methods, :repeat_payment_token, :text
    remove_column :payment_methods, :initial_payment_id
  end
end
