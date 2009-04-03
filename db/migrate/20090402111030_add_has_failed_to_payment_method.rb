class AddHasFailedToPaymentMethod < ActiveRecord::Migration
  def self.up
    add_column :payment_methods, :has_failed, :boolean
  end

  def self.down
    remove_column :payment_methods, :has_failed
  end
end
