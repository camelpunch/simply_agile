class AddColumnsToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :user_id, :integer
    add_column :invoices, :organisation_name, :string
    add_column :invoices, :payment_plan_name, :string
    add_column :invoices, :payment_plan_price, :decimal, 
      :precision => 5, :scale => 2
    add_column :invoices, :date, :date
  end

  def self.down
    remove_column :invoices, :date
    remove_column :invoices, :payment_plan_price
    remove_column :invoices, :payment_plan_name
    remove_column :invoices, :organisation_name
    remove_column :invoices, :user_id
  end
end
