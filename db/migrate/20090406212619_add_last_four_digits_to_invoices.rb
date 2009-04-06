class AddLastFourDigitsToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :last_four_digits, :integer
  end

  def self.down
    remove_column :invoices, :last_four_digits
  end
end
